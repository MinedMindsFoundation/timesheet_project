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
p user_checked
erb :landing, locals:{user_info:user_info, user_email:user_email, admin_check:admin_check, user_checked:user_checked}
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

