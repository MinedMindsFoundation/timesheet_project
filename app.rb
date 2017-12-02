require "sinatra"
require 'pg'
require_relative 'g_calendar.rb'
require_relative 'functions.rb'
require_relative 'user_id.rb'
require_relative 'cte_func.rb'
require 'net/smtp'
# require_relative 'login_func'
enable :sessions 
load './local_ENV.rb' if File.exist?('./local_ENV.rb')


# Initial "get" leads to login page
get "/" do 
    login_message = params[:login_message]
    session[:message] = '' 
    erb :login, locals:{login_message:login_message}, :layout => :post
end

# comming from login.erb
post '/login' do 

session[:first_name] = params[:first_name]
session[:last_name] = params[:last_name]
session[:email] = params[:email]

    if login_check?(session[:email])
        session[:user_id] = get_id(session[:email])
        db_params = {
            host: ENV['host'],
            port: ENV['port'],
            dbname: ENV['dbname'],
            user: ENV['user'],
            password: ENV['password']
        }
        redirect "/to_landing"
    else  
        redirect '/'
    end
end

post '/sso_login' do
    username = params[:username]
    password = params[:password]
    if ssologin_check?(username,password) == true
        session[:user_id] = username
        redirect '/to_landing'
    else
        redirect '/'
    end
end    

post '/logout' do
    redirect '/'
end

# leads to landing page 
get "/to_landing" do
    session[:employees] = get_supervisees(session[:user_id])
    names_to_use = session[:employees]
    names_to_use << session[:user_id]
    session[:names_arr] = get_names(names_to_use)
    user_class = User.new(session[:user_id])
    user_list = user_class.users_list
    time_hash = user_class.get_last_times
    user_info =  database_info(session[:user_id])
    # p user_info
    user_email = database_email_check(session[:user_id])
    # pay_period = pay_period(Time.now.utc)
    session[:admin_check] = database_admin_check(session[:user_id])
    # user_checked = database_emp_checked()
    # p user_checked
    pay_period = pay_period(Time.new)
    times = pull_in_and_out_times(session[:user_id],pay_period)
    todays_time = pull_in_and_out_times(session[:user_id],[DateTime.now.strftime('%Y-%m-%d'),DateTime.now.strftime('%Y-%m-%d')])
    erb :landing, locals:{user_list:user_list,time_hash:time_hash,todays_time:todays_time,pay_period:pay_period,times:times,user_info:user_info, user_email:user_email, admin_check: session[:admin_check],}
end

#post comming from landing and records start of lunch
post "/lunch_in" do 
   if check_lunch_in(session[:user_id])
    time = get_time
        submit_lunch_in(session[:user_id],time[0])
        session[:message] = "Lunch Started"
   else 
        session[:message] = "Unable to Submit Action"
   end
   redirect "/to_landing"
end

# post comming from landing and records end of lunch
post "/lunch_out" do 
    if check_lunch_out(session[:user_id])
        time = get_time
         submit_lunch_out(session[:user_id],time[0])
         session[:message] = "Lunch Ended"
    else 
         session[:message] = "Unable to Submit Action"
    end
    redirect "/to_landing"
 end

# post coming from landing to whos_in
post '/to_whos_in' do
redirect '/whos_in'
end

# leads to page where user can see who's clock
get '/whos_in' do
    users = who_is_clocked_in()
    erb :whos_in, locals:{users:users}

end

post "/return" do
redirect "/to_landing"
end

get '/vac_time_request' do
    user_info =  database_info(session[:user_id])
    user_email = database_email_check(session[:user_id])
    user_pto = pto_time(session[:user_id])
    user_vac = get_vacation_time(session[:user_id])
    user_sic = sic_time(session[:user_id])
    pto_requests = pull_employee_pto_request(session[:employees])
    user_pto_request = get_users_pto_request(session[:user_id])
    hire_date = pull_out_date_of_hire(session[:user_id])
    pto_stamp = pull_pto_stamp(session[:user_id])
    newpto = timeoffbiuldup(session[:user_id],user_info,user_pto,hire_date,pto_stamp,user_vac,user_sic)
    user_pto = pto_time(session[:user_id])
    user_vac = get_vacation_time(session[:user_id])
    user_sic = sic_time(session[:user_id])
    #p "...#{hire_date}.............#{user_pto}...........#{pto_stamp}..........#{newpto}"
    erb :pto_request, locals:{user_pto_request:user_pto_request,pto_requests:pto_requests,user_info:user_info, user_email:user_email, user_pto: user_pto, user_vac: user_vac, user_sic: user_sic}
end

post '/pto_email' do 
    type_of_pto = params[:pto_type]
    comment = params[:comment]
    start_date = params[:start_vac]
    end_date = params[:end_vac]
    user_info =  database_info(session[:user_id])
    user_pto = pto_time(session[:user_id])
    pto_request_db_add(session[:user_id],start_date,end_date,type_of_pto)
    if user_pto == "0"
        email_for_no_pto(user_info, user_pto, ype_of_pto)
        session[:pto_message] = "You have no PTO to request."
        redirect "/to_landing"
    else 
        send_email(start_date, end_date, user_info, user_pto, type_of_pto)
        session[:pto_message] = "Your Request was emailed."
    end 
    # p start_date
    # p end_date
    # p user_info
    redirect "/to_landing"
end

# post comming from landing page
post "/clock_in" do
    location = params[:location]
    # p location
    if time_in_check?(session[:user_id])
        time = get_time()
        submit_time_in(session[:user_id],location,time[0],time[1])
        session[:message] = "Time in Submitted"
    else
        session[:message] = "Already Submitted Time In"
    end
    redirect "/to_landing"
 end

# post comming from landing page
post "/clock_out" do
    if time_out_check?(session[:user_id]) && time_out_lunch_check?(session[:user_id])
        time = get_time()
        submit_time_out(session[:user_id],time[0],time[1])
        session[:message] = "Time Out Submitted"
    elsif time_out_lunch_check?(session[:user_id])
        session[:message] =  "Unable to Submit Action"
    else
        session[:message] = "Unable to Submit Action"
    end
    redirect "/to_landing"
end

get "/add_user" do
    msg = ""
    erb :admin_emplist, locals:{names_arr:session[:names_arr],msg:msg}
end

post "/add_to_user_list" do
    msg="User Added"
    user_id=params[:user_id_new]
    first_name=params[:first_name].capitalize
    last_name=params[:last_name].capitalize
    email=params[:email]
    supervisor=params[:supervisor]
    department=params[:department]
    job=params[:job]
    doh=params[:doh]
    pto=params[:pto]
    vacation=params[:vacation]
    sick=params[:sick]
    admin_access = "No"
    user_info = []
    user_info << first_name
    user_info << last_name
    send_email_for_adding_a_new_user(user_info, email)
    add_user(user_id,email,first_name,last_name,pto,supervisor,admin_access,doh,department,job,vacation,sick)
    pto_time_stamp(user_id)
    erb :admin_emplist, locals:{names_arr:session[:names_arr],msg:msg}
    # erb :admin_emplist, locals:{msg:msg}
end

get "/edit_user" do
    admin_list = admin_emp_list()
    new_admin_list = []
    employees = session[:employees]
    admin_list = get_names(employees)
    # p admin_list
    erb :admin_empmng, locals:{admin_list:admin_list}
end

post "/update_emp" do
    session[:edit_user] = params[:info]
    choice = params[:choose]
    # p session[:edit_user]
    # p choice
    if session[:edit_user] == [] || session[:edit_user] == nil
        admin_list = admin_emp_list()
        erb :admin_empmng, locals:{admin_list:admin_list}
    else
        if choice == "Info"
            redirect "/employee_info"
        elsif choice == "Update"
            redirect "/update_emp_page"
        elsif choice == "Delete"
            user_hierarchies[1].each_with_index do |users, index|
                if user_hierarchies[0].to_i > users.to_i
                    delete_emp(session[:edit_user][index])
                end
            end            
            admin_list = admin_emp_list()
            erb :admin_empmng, locals:{admin_list:admin_list}
        end
    end
end

get "/update_emp_page" do
    pay_period = pay_period(Time.new)
    time_table = []
    session[:editing_users] =[]
    session[:edit_user].each do |times|
        time_table << pull_in_and_out_times(times,pay_period)
    end
    session[:edit_user].each do |user|
        session[:editing_users] << user_info = emp_info(user)
    end
    # p session[:editing_users]
    # p users
    # p time_table
    msg = ""
    erb :admin_emp_updating, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table, msg:msg, sup_arr:session[:names_arr]}
end

post "/emp_updated" do
    new_info = params[:info].each_slice(11).to_a
    other_info = params[:info]
    # p new_info
    # p session[:edit_user]
    # p other_info
    new_info.each_with_index do |info, index|
        # p session[:edit_user][index]
        # p info
        # p index
        update_user(session[:edit_user][index], info)
    end
    pay_period = pay_period(Time.new)
    time_table = []
    session[:editing_users] =[]
    session[:edit_user].each do |times|
        time_table << pull_in_and_out_times(times,pay_period)
    end
    session[:edit_user].each do |user|
        session[:editing_users] << user_info = emp_info(user)
    end
    # p session[:editing_users]
    # p users
    # p time_table
    msg = "User Updated"
    erb :admin_emp_updating, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table, msg:msg, sup_arr:session[:names_arr]}
end

get "/employee_info" do
    pay_period = pay_period(Time.new)
    time_table = []
    session[:editing_users] =[]
    session[:edit_user].each do |times|
        time_table << pull_in_and_out_times(times,pay_period)
    end
    session[:edit_user].each do |user|
        session[:editing_users] << user_info = emp_info(user)
    end
    # p emp_info(user)
    # p session[:editing_users]
    erb :emp_info, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table}
end

post "/update_timesheet" do
    date_of_fix = params[:time_fix]
    session[:selected_id] =params[:selected_id]
    session[:times_shown] = time_date_fix(session[:selected_id],date_of_fix)
    user_info = emp_info(session[:selected_id])
    # p date
    # p session[:times_shown]
    erb :admin_time_fix, locals:{user_info:user_info,date_of_fix:date_of_fix, times_shown:session[:times_shown]}
end

post "/update_time_sheet" do
    choice = params[:choose]
    selected_time = params[:times]
    new_time = params[:edited_times].each_slice(7).to_a
    if selected_time == nil || selected_time == []
        pay_period = pay_period(Time.new)
        time_table = []
        session[:editing_users] =[]
        session[:edit_user].each do |times|
            time_table << pull_in_and_out_times(times,pay_period)
        end
        session[:edit_user].each do |user|
            session[:editing_users] << user_info = emp_info(user)
        end
        # p session[:editing_users]
        # p users
        # p time_table
        msg = "No Time Selected Or Updated"
        erb :admin_emp_updating, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table, msg:msg, sup_arr:session[:names_arr]}
    else
        if choice == "Update"
            # p session[:times_shown]
            # p new_time
            # p selected_time
            new_time_edit = []
            final_time = []
            new_time.each do |times|
                times.each do |positions|
                    if positions == " " || positions == "" || positions == nil
                        positions = "N/A"
                    end
                    new_time_edit << positions
                end
            end
                final_time << new_time_edit.each_slice(7).to_a
            selected_time.each do |position|
                positions = position.to_i
                # p positions
                # p new_time_edit
                # p final_time.flatten.each_slice(7).to_a
                final_edit_time = final_time.flatten.each_slice(7).to_a
                # p final_edit_time[positions]
                original_time = session[:times_shown][positions]
                # p original_time
                # p original_time[0]
                # p original_time[4]
                timetable_fix(session[:selected_id], original_time[4], original_time[0], final_edit_time[positions])
            end
            pay_period = pay_period(Time.new)
            time_table = []
            session[:editing_users] =[]
            session[:edit_user].each do |times|
                time_table << pull_in_and_out_times(times,pay_period)
            end
            session[:edit_user].each do |user|
                session[:editing_users] << user_info = emp_info(user)
            end
            msg = "Time Updated"
            erb :admin_emp_updating, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table, msg:msg, sup_arr:session[:names_arr]}
        elsif choice == "Delete"
            selected_time.each do |position|
                positions = position.to_i
                original_time = session[:times_shown][positions]
                timetable_delete(session[:selected_id], original_time[4], original_time[0])
            end
            
            pay_period = pay_period(Time.new)
            time_table = []
            session[:editing_users] =[]
            session[:edit_user].each do |times|
                time_table << pull_in_and_out_times(times,pay_period)
            end
            session[:edit_user].each do |user|
                session[:editing_users] << user_info = emp_info(user)
            end
            msg = "Time Deleted"
            erb :admin_emp_updating, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table, msg:msg, sup_arr:session[:names_arr]}
        end
    end
end

get "/reload" do
     user_id = params[:user_id]
    #  arr.gsub!(/[^0-9A-Za-z.,\-]/, '')
    #   user_id = arr.split(",")
    user_class = User.new(session[:user_id])
      time_hash = user_class.get_last_times
    # user_check =database_emp_checked
    # users = who_is_clocked_in()
    # erb :reload, locals:{users:users,user_checked:user_checked}, :layout => :post
    erb :reload, locals:{time_hash:time_hash,user:user_id}, :layout => :post
end

post "/approval" do
    approval = params.values
    submit_pto_approval(approval)
    session[:message] = "request submitted"
    redirect "/vac_time_request"
end

post "/to_admin_emplist" do
    admin_list = admin_emp_list()
    erb :admin_empmng, locals:{admin_list:admin_list}
end