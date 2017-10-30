require 'date'
require 'pg'
load './local_env.rb' if File.exist?('./local_env.rb')

#gets date & time from system
def get_time()
    arr = []
    x = Time.now.utc + Time.zone_offset('-0400')
    # x.zone = "-04:00"
    arr << x.strftime('%H:%M')
    arr << x.strftime('%m/%d/%Y')
    arr
end

def vac_time()
    arr = []
    x = Time.now.utc + Time.zone_offset('-0400')
    x.strftime('%Y-%m-%d')
end

#checks if email is in the database
def login_check?(email)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    check = db.exec("SELECT * FROM email WHERE email = '#{email}'")
    if check.num_tuples.zero? == false
        true
    else
        false
    end
end

#submits time and date into timesheet  
def submit_time_in(user_id,time,date)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    db.exec("UPDATE info SET  status= 'in' WHERE user_id = '#{user_id}'")
    db.exec("INSERT INTO timesheet_#{user_id}(time_in,time_out,date)VALUES('#{time}','N/A','#{date}')")
end

#submits time out to timesheet table
def submit_time_out(user_id,time)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
        db.exec("UPDATE info SET  status= 'out' WHERE user_id = '#{user_id}'")
        db.exec("UPDATE timesheet_#{user_id} SET time_out = '#{time}' WHERE time_out = 'N/A'")

end

# Gets user_id from email table
def get_id(email)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    user_id = db.exec("SELECT user_id FROM email WHERE email = '#{email}'").values
    user_id.flatten.first
end

# def add_info(user_id,email,first_name,last_name,admin)
# db_params = {
#     host: ENV['host'],
#     port: ENV['port'],
#     dbname: ENV['dbname'],
#     user: ENV['user'],
#     password: ENV['password']
#     }
#     db = PG::Connection.new(db_params)
    
#     db.exec("insert into names(user_id,first_name,last_name)VALUES('#{user_id}','#{first_name}','#{last_name}')")
#     db.exec("insert into emails(user_id,emails)VALUES('#{user_id}','#{email}')")
#     db.exec("insert into admin(user_id,admin)VALUES('#{user_id}','#{admin}')")

# end
# adds user to database
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

# returns true if user isnt clocked in
def time_in_check?(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    check = db.exec("SELECT * FROM timesheet_#{user_id} WHERE time_out = 'N/A'")
    if check.num_tuples.zero? 
        true
    else
        false
    end
    
end

#returns true if user is not clocked out
def time_out_check?(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    check = db.exec("SELECT * FROM timesheet_#{user_id} WHERE time_out = 'N/A'")
    if check.num_tuples.zero? == false
        true
    else
        false
    end
end

def database_info(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
        user_first = db.exec("SELECT first_name FROM info WHERE user_id = '#{user_id}'").values
        user_last = db.exec("SELECT last_name FROM info WHERE user_id = '#{user_id}'").values
        user_name = []
        user_name << user_first.flatten.first
        user_name << user_last.flatten.first
        user_name
end

def database_email_check(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
        user_email = db.exec("SELECT email FROM email WHERE user_id = '#{user_id}'").values
        user_email.flatten.first
end