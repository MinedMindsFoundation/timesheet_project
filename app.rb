require "sinatra"
require 'pg'
# require_relative 'login_func'
enable :sessions 
load './local_env.rb' if File.exist?('./local_env.rb')


# Initial "get" leads to login page
get "/" do 
erb :login
end

# comming from login.erb
post "/login" do

redirect "/to_landing?"
end

# leads to landing page 
get "/to_landing" do
erb :landing
end

# post comming from landing page
post "/clock_out" do
time = params[:time]
"this is the time #{time}"
end
