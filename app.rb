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
post "/login" do
first_name = params[:first_name]
last_name = params[:last_name]
email = params[:email]
p first_name
p last_name
p email
redirect "/to_landing?"
end

# leads to landing page 
get "/to_landing" do
erb :landing
end

# post comming from landing page
post "/clock_in" do
time = get_time()
"this is the time #{time}"
 end

# post comming from landing page
post "/clock_out" do
time = get_time()
"this is the time #{time}"
end

