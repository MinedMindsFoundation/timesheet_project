require "sinatra"

get "/" do
erb :login
end




get "/info" do
erb :landing
end