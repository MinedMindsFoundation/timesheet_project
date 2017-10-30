require "sinatra"
require 'pg'
require_relative 'functions.rb'
# require_relative 'login_func'
enable :sessions 
load './local_env.rb' if File.exist?('./local_env.rb')


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


