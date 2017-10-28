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
<<<<<<< HEAD
post "/login" do
first_name = params[:first_name]
last_name = params[:last_name]
email = params[:email]
p first_name
p last_name
p email
redirect "/to_landing?"
end

=======
post '/login' do 
session[:first_name] = params[:first_name]
session[:last_name] = params[:last_name]
session[:email] = params[:email]

redirect "/to_landing?"
end



>>>>>>> 3d1e9fa702343209046f72124c6131b6efe6d008
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


