require "sinatra"
require 'pg'
require_relative 'functions.rb'
require 'net/smtp'
# require_relative 'login_func'
enable :sessions 
load './local_ENV.rb' if File.exist?('./local_ENV.rb')


# Initial "get" leads to login page
get "/" do 
session[:message] = ''
erb :login
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


# leads to landing page 
get "/to_landing" do
user_info =  database_info(session[:user_id])
user_email = database_email_check(session[:user_id])
pay_period = pay_period(Time.now.utc)
admin_check = database_admin_check(session[:user_id])
user_checked = database_emp_checked()
# p user_checked
pay_period = pay_period(Time.new)
times = pull_in_and_out_times(session[:user_id],pay_period)
erb :landing, locals:{pay_period:pay_period,times:times,user_info:user_info, user_email:user_email, admin_check:admin_check, user_checked:user_checked}
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
redirct "/to_landing"
end

#post coming from landing page for vac request
post '/vac_time_request' do
    user_info =  database_info(session[:user_id])
    user_email = database_email_check(session[:user_id])
    erb :pto_request, locals:{user_info:user_info, user_email:user_email}
end

post '/pto_email' do 
    start_date = params[:start_vac]
    end_date = params[:end_vac]
    user_info =  database_info(session[:user_id])
    # p start_date
    # p end_date
    # p user_info
    send_email(start_date, end_date, user_info)
    redirect "/to_landing"
end

# post comming from landing page
post "/clock_in" do
    
    if time_in_check?(session[:user_id])
        time = get_time()
        submit_time_in(session[:user_id],time[0],time[1])
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
        submit_time_out(session[:user_id],time[0])
        session[:message] = "Time Out Submitted"
    else
        session[:message] =  "Already Submitted Time Out"
    end
    redirect "/to_landing"
end

post "/add_user" do
    erb :admin_emplist
end

post "/add_to_user_list" do
    user_id=params[:user_id_new]
    first_name=params[:first_name]
    last_name=params[:last_name]
    email=params[:email]
    admin=params[:admin]
    add_user(user_id,email,first_name,last_name,"0",admin,"N/A")
    redirect '/add_user'
end

post "/edit_user" do
    admin_list = admin_emp_list()
    # p admin_list
    erb :admin_empmng, locals:{admin_list:admin_list}
end