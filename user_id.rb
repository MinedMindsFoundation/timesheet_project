require 'pg'

class User
    
    attr_accessor :users_list ,:user_data
    def initialize(user_id)
    
        @db_params = {
            host: ENV['host'],
            port: ENV['port'],
            dbname: ENV['dbname'],
            user: ENV['user'],
            password: ENV['password']
        }
        @db = PG::Connection.new(@db_params)
        @users_list = @db.exec("Select user_id From info_new").values
        @user_data = @db.exec("Select info_new.*,admin_status.admin, admin_status.hierarchy From info_new,admin_status WHERE admin_status.user_id = '#{user_id}' And info_new.user_id = '#{user_id}'").values.flatten
    end
        
end