require 'date'
require 'pg'
load './local_env.rb' if File.exist?('./local_env.rb')

def get_time()
    DateTime.now
end

def add_info(user_id,email,first_name,last_name,admin)
db_params = {
    host: ENV['host'],
    port: ENV['port'],
    dbname: ENV['dbname'],
    user: ENV['user'],
    password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    
    db.exec("insert into names(user_id,first_name,last_name)VALUES('#{user_id}','#{first_name}','#{last_name}')")
    db.exec("insert into emails(user_id,emails)VALUES('#{user_id}','#{email}')")
    db.exec("insert into admin(user_id,admin)VALUES('#{user_id}','#{admin}')")

end

add_info("scstew","scottmstewart2@gmail.com","Scott","Stewart","Yes")