require 'date'
require 'pg'
load './local_env.rb' if File.exist?('./local_env.rb')

def get_time()
    DateTime.now
end

def login_check?(email)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    check = db.exec("SELECT * FROM emails WHERE emails = '#{email}'")
    if check.num_tuples.zero? == false
        true
    else
        false
    end
end

def submit_time_in(user_id,time)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    
    db.exec("INSERT INTO timesheet(user_id,clock_in)VALUES('#{user_id}','#{time}')")
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

def add_user(user_id,email,first_name,last_name,pto,admin,doh)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    db.exec("insert into info(user_id,first_name,last_name,pto,admin,status,doh)VALUES('#{user_id}','#{first_name}','#{last_name}','#{pto}','#{admin}','out','#{doh}')")
    db.exec("insert into email(user_id,email)VALUES('#{user_id}','#{email}')")
    db.exec("create table timesheet_#{user_id} (time_in text,time_out text,date text)")

end

add_user("scstew","abearkin@hotmail.com","Scott","Stewart","0","N","N/A")