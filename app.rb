require "sinatra"
require 'pg'
require_relative 'functions.rb'
# require_relative 'login_func'
enable :sessions 
load './local_env.rb' if File.exist?('./local_env.rb')


# Initial "get" leads to login page
get "/" do 
erb :login
end

# comming from login.erb
post '/login' do 
session[:first_name] = params[:first_name]
session[:last_name] = params[:last_name]
session[:email] = params[:email]
    if login_check?(session[:email])
        session[:user_id] = get_id(sessions[:email])
        redirect "/to_landing?"
    else
        redirect '/?'
    end
end


# leads to landing page 
get "/to_landing" do
erb :landing
end

# post comming from landing page
post "/clock_in" do
time = get_time()
submit_time_in(user_id,time[0],time[1])
"this is the time #{time}"
 end

# post comming from landing page
post "/clock_out" do
time = get_time()
"this is the time #{time}"
end

