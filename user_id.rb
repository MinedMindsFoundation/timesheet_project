require 'pg'

class User
    
    attr_accessor :users_list ,:user_data,:db
    def initialize(user_id)
        @db_params = {
            host: ENV['host'],
            port: ENV['port'],
            dbname: ENV['dbname'],
            user: ENV['user'],
            password: ENV['password']
        }
        @db = PG::Connection.new(@db_params)
        @users_list = @db.exec("Select * From info_new").values
        @user_data = @db.exec("Select info_new.*,admin_status.admin, admin_status.hierarchy From info_new,admin_status WHERE admin_status.user_id = '#{user_id}' And info_new.user_id = '#{user_id}'").values.flatten
        @db.close
    end
       
    def get_last_times
        @db = PG::Connection.new(@db_params)
        @hash = {}
        users_list.each do |user_id|
            arr = @db.exec("SELECT * FROM timesheet_new WHERE user_id = '#{user_id[0]}' AND time_out = 'N/A'")
            if arr.num_tuples.zero?
                @hash["#{user_id[0]}"] = [user_id[0],"empty","empty","empty","empty","empty","empty","empty"]
            else
            @hash["#{user_id[0]}"] = arr.values.flatten
            end
        end
        @hash
    end


end