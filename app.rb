require "sinatra"
require 'pg'
require_relative 'functions.rb'
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
p "#{session[:email]} email address is here"
    if login_check?(session[:email])
        session[:user_id] = get_id(session[:email])
        redirect "/to_landing?"
    else
        redirect '/?'
    end
end


# leads to landing page 
get "/to_landing" do
user_info =  database_info(session[:user_id])
user_email = database_email_check(session[:user_id]) 
erb :landing, locals:{user_info:user_info, user_email:user_email}
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


