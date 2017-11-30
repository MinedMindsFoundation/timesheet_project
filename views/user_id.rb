class User_onfo
    
    attr_accessor 
    def initialize(user_id)

    def initialize
        @db_params = {
            host: ENV['host'],
            port: ENV['port'],
            dbname: ENV['dbname'],
            user: ENV['user'],
            password: ENV['password']
        }
        @users_list = db.exec("Select user_id From info.new").values
        @user_info = db.exec("Select info_new.*,admin_status.* From info_new,admin_status WHERE user_id = #{user_id}")
        
end