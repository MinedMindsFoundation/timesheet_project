require "sinatra"
require 'pg'
require_relative 'login_func'
enable :sessions 
load './local_env.rb' if File.exist?('./local_env.rb')

get "/" do 
message = params[:message]
    if message == nil 
        message = "Please Enter Username and Password"
    end
    erb :login, locals:{message: message}
end

post "/create_login" do
	redirect "/make_login"
end
get "/make_login" do
	erb :new_login
end

post "/made_login" do
	user = params[:user]
	pass = params[:pass]
	message = add_to_login(user,pass)
	redirect "/?message=" + message
end


post "/login" do
	user = params[:username]
	pass = params[:password]
	if check_creds?(user,pass) == true 
		redirect "/info"
	else 
		message = "incorrect username or password"
		redirect "/?message=" + message
	end
end 
 


