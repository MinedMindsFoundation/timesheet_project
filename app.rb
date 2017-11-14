require "sinatra"
require 'pg'
require_relative 'g_calendar.rb'
require_relative 'functions.rb'
require 'net/smtp'
# require_relative 'login_func'
enable :sessions 
load './local_ENV.rb' if File.exist?('./local_ENV.rb')


# Initial "get" leads to login page
get "/" do 
    login_message = params[:login_message]
    session[:message] = '' 
    erb :login, locals:{login_message:login_message}
end

# comming from login.erb
post '/login' do 
session[:first_name] = params[:first_name]
session[:last_name] = params[:last_name]
session[:email] = params[:email]

    if login_check?(session[:email])
        session[:user_id] = get_id(session[:email])
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
    user_info =  database_info(session[:user_id])
    user_email = database_email_check(session[:user_id])
    pay_period = pay_period(Time.now.utc)
    session[:admin_check] = database_admin_check(session[:user_id])
    user_checked = database_emp_checked()
    # p user_checked
    pay_period = pay_period(Time.new)
    times = pull_in_and_out_times(session[:user_id],pay_period)
erb :landing, locals:{pay_period:pay_period,times:times,user_info:user_info, user_email:user_email, admin_check: session[:admin_check], user_checked:user_checked}
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

#post coming from landing page for vac request
post '/vac_time_request' do
    user_info =  database_info(session[:user_id])
    user_email = database_email_check(session[:user_id])
    user_pto = pto_time(session[:user_id])
    pto_requests = pull_pto_request()
    erb :pto_request, locals:{pto_requests:pto_requests,user_info:user_info, user_email:user_email, user_pto: user_pto}
end

post '/pto_email' do 
    start_date = params[:start_vac]
    end_date = params[:end_vac]
    user_info =  database_info(session[:user_id])
    user_pto = pto_time(session[:user_id])
    pto_request_db_add(session[:user_id],start_date,end_date)
    if user_pto == "0"
        email_for_no_pto(user_info, user_pto)
        session[:pto_message] = "You have no PTO to request."
        redirect "/to_landing"
    else 
        send_email(start_date, end_date, user_info, user_pto)
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
    p location
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
    if time_out_check?(session[:user_id])
        time = get_time()
        submit_time_out(session[:user_id],time[0],time[1])
        session[:message] = "Time Out Submitted"
    else
        session[:message] =  "Already Submitted Time Out"
    end
    redirect "/to_landing"
end

post "/add_user" do
    msg = ""
    erb :admin_emplist, locals:{msg:msg}
end

post "/add_to_user_list" do
    msg="User Added"
    user_id=params[:user_id_new]
    first_name=params[:first_name]
    last_name=params[:last_name]
    email=params[:email]
    admin=params[:admin]
    pto=params[:pto]
    dot=params[:dot]
    user_info = []
    user_info << first_name
    user_info << last_name
    send_email_for_adding_a_new_user(user_info, email)
    add_user(user_id,email,first_name,last_name,pto,admin,dot)
    erb :admin_emplist, locals:{msg:msg}
end

post "/edit_user" do
    admin_list = admin_emp_list()
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
            session[:edit_user].each do |user|
                delete_emp(user)
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
    # p users
    # p time_table
    erb :admin_emp_updating, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table}
end

post "/emp_updated" do
    new_info = params[:info].each_slice(7).to_a
    # p new_info
    # p session[:edit_user]
    new_info.each_with_index do |info, index|
        # p session[:edit_user][index]
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
    # p users
    # p time_table
    erb :admin_emp_updating, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table}
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
    # p user_info
    erb :emp_info, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table}
end

post "/update_timesheet" do
    date_of_fix = params[:time_fix]
    session[:selected_id] =params[:selected_id]
    session[:times_shown] = time_date_fix(session[:selected_id],date_of_fix)
    user_info = emp_info(session[:selected_id])
    # p session[:times_shown]
    erb :admin_time_fix, locals:{user_info:user_info,date_of_fix:date_of_fix, times_shown:session[:times_shown]}
end

post "/update_time_sheet" do
    choice = params[:choose]
    selected_time = params[:times]
    new_time = params[:edited_times].each_slice(7).to_a
    if selected_time == nil || selected_time == []
        admin_list = admin_emp_list()
        erb :admin_empmng, locals:{admin_list:admin_list}
    else
        if choice == "Update"
            # p session[:times_shown]
            # p new_time
            # p selected_time
            selected_time.each do |position|
                positions = position.to_i
                # p positions
                # p new_time[positions]
                original_time = session[:times_shown][positions]
                # p original_time
                # p original_time[0]
                # p original_time[4]
            timetable_fix(session[:selected_id], original_time[4], original_time[0], new_time[positions])
            end
        elsif choice == "Delete"
            selected_time.each do |position|
                positions = position.to_i
                original_time = session[:times_shown][positions]
                timetable_delete(session[:selected_id], original_time[4], original_time[0])
            end
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
        # p users
        # p time_table
        erb :admin_emp_updating, locals:{users:session[:editing_users],pay_period:pay_period,time_table:time_table}
    end
end

get "/reload" do
    user_checked = database_emp_checked()
    erb :reload, locals:{user_checked:user_checked}, :layout => :post
end

post "/approval" do
    approval = params.values
    submit_pto_approval(approval)
    session[:message] = "request submitted"
    redirect "/to_landing"
end

post "/to_admin_emplist" do
    admin_list = admin_emp_list()
    erb :admin_empmng, locals:{admin_list:admin_list}
end