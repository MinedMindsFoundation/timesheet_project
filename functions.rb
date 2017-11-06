require 'date'
require "time"
require 'pg'
require 'net/smtp'
require 'mail'
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
    # db.exec("UPDATE info SET  status= 'in' WHERE user_id = '#{user_id}'")
    db.exec("INSERT INTO timesheet_new(user_id,time_in,lunch_start,lunch_end,time_out,date)VALUES('#{user_id}','#{time}','N/A','N/A','N/A','#{date}')")
    db.close
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
        # db.exec("UPDATE info SET  status= 'out' WHERE user_id = '#{user_id}'")
        db.exec("UPDATE timesheet_new SET time_out = '#{time}' WHERE user_id = '#{user_id}' AND time_out = 'N/A'")
        db.close

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
    db.close
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
    db.exec("insert into info_new(user_id,first_name,last_name,date_of_hire)VALUES('#{user_id}','#{first_name}','#{last_name}','#{doh}')")
    db.exec("insert into pto(user_id,pto)VALUES('#{user_id}','0')")
    db.exec("insert into admin_status(user_id,admin)VALUES('#{user_id}','#{admin}')")
    db.exec("insert into email(user_id,email)VALUES('#{user_id}','#{email}')")
    db.close
    
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
    check = db.exec("SELECT * FROM timesheet_new WHERE user_id = '#{user_id}' AND time_out = 'N/A'")
    db.close
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
    check = db.exec("SELECT * FROM timesheet_new WHERE user_id = '#{user_id}' AND time_out = 'N/A'")
    db.close
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
        user_first = db.exec("SELECT first_name FROM info_new WHERE user_id = '#{user_id}'").values
        user_last = db.exec("SELECT last_name FROM info_new WHERE user_id = '#{user_id}'").values
        db.close            
        user_name = []
        user_name << user_first.flatten.first
        user_name << user_last.flatten.first
        user_name
end

def database_admin_check(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
    db = PG::Connection.new(db_params)
    user_admin = db.exec("SELECT admin FROM admin_status WHERE user_id = '#{user_id}'").values
    db.close 
    user_admin.flatten.first
end

def database_emp_checked()
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    # inorout = "in"
    user_checked = []
    db = PG::Connection.new(db_params)
    user = db.exec("SELECT user_id FROM timesheet_new WHERE time_out = 'N/A'").values
    # p user
    user.each do |user_id|
    user_checked << db.exec("SELECT first_name, last_name FROM info_new WHERE user_id = '#{user_id[0]}'").values
    user_checked << time_converter(db.exec("SELECT time_in FROM timesheet_new WHERE time_out = 'N/A' AND user_id = '#{user_id[0]}'").values.flatten.first)
    # p user_checked
    end
    db.close
    next_checked = user_checked.flatten
    next_checked.each_slice(3)
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
        db.close()
        user_email.flatten.first
end

def admin_emp_list()
	db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    data = []
    db = PG::Connection.new(db_params)
    users = db.exec("SELECT user_id, first_name, last_name FROM info_new").values
    # emails = db.exec("SELECT email FROM email").values
    db.close
    # users << emails
    users.each do |user|
        data << user
    end
    data
end





def add_email(user_id,email)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
        db.exec("INSERT INTO email(user_id,email)VALUES('#{user_id}','#{email}')")
        db.close()
end

def pay_period(now)
    
    add_2weeks = (14 * 60 * 60 * 24)
    endday = (13 * 60 * 60 * 24)  + (23 * 60 *60 ) +(59*60) + 59

    start_date = Time.utc(2017,10,30)
    end_date = start_date + endday
        until now < end_date do
            start_date += add_2weeks   
            end_date = start_date + endday
        end
    arr = [start_date.strftime('%Y-%m-%d'),end_date.strftime('%Y-%m-%d')]
    arr
end


def pull_in_and_out_times(user_id,date_range)
    
    # p start_date = date_range[0].strftime('%Y-%m-%d')\
    start_date = date_range[0]
    end_date = date_range[1]
    # end_date
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
       
        info = db.exec("SELECT time_in, lunch_start,lunch_end, time_out, date  FROM timesheet_new WHERE user_id = '#{user_id}' AND date >= '#{start_date}'::date AND date <= '#{end_date}'::date").values
        db.close()
     info
end

#  pull_data_for_pay_period("lukeid",pay_period(Time.new))
# database_email_check('devid')

# fuction that send the admin an email for pto request

def send_email(start_vec, end_vac, full_name, pto) 
Mail.defaults do
    delivery_method :smtp,
    address: "email-smtp.us-east-1.amazonaws.com",
    port: 587,
    :user_name  => ENV['a3smtpuser'],
    :password   => ENV['a3smtppass'],
    :enable_ssl => true
  end
    email_body = "#{full_name[0]} #{full_name[1]} is requesting thes dates #{start_vec} #{end_vac}. They have #{pto} day to request."
  mail = Mail.new do
      from         ENV['from']
      to           'billyjacktattoos@gmail.com'
      subject      "PTO Request"

      html_part do
        content_type 'text/html'
        body       email_body
      end
  end
  mail.deliver!
end

def time_converter(time)
    arr = time.split(":")
    if arr[0] == "00"
        "12:#{arr[1]} am"  
    elsif arr[0].to_i <= 12
        "#{arr[0]}:#{+arr[1]} am"
    else
        arr[0] = arr[0].to_i % 12
        "#{arr[0]}:#{+arr[1]} pm"
    end
end

def who_is_clocked_in()
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
    arr_in = []
    arr_out = []
    users = db.exec("SELECT user_id FROM info_new").values
    users.flatten.each do |user_id|
    name = database_info(user_id)
    p user_id
        if time_out_check?(user_id) == true
            arr_in << "#{name[0]} #{name[1]}"
        else
            arr_out << "#{name[0]} #{name[1]}"
        end
    end
    [arr_in,arr_out]
end

# returns true if lunch hasnt already been started
def check_lunch_in(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
    check = db.exec("SELECT * FROM timesheet_new WHERE user_id = '#{user_id}' AND lunch_start = 'N/A' AND time_out = 'N/A'")
    db.close
    if check.num_tuples.zero? == false
        true
    else
        false
    end   
end

# submits lunch start time
def submit_lunch_in(user_id,time)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
    db.exec("UPDATE timesheet_new SET lunch_start = '#{time}' WHERE user_id = '#{user_id}' AND time_out = 'N/A'")
    db.close
end

# returns true if lunch has started 
def check_lunch_out(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
    check = db.exec("SELECT *FROM timesheet_new WHERE user_id = '#{user_id}' AND lunch_start != 'N/A' AND lunch_end = 'N/A'  AND time_out = 'N/A'")
    db.close
    if check.num_tuples.zero? == false
        true
    else
        false
    end
end

#function for submitting lunch end
def submit_lunch_out(user_id,time)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
    db.exec("UPDATE timesheet_new SET lunch_end = '#{time}' WHERE user_id = '#{user_id}' AND time_out = 'N/A'")
    db.close
end


# func to get the user pto time

def pto_time(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
        user_pto = db.exec("SELECT pto FROM pto WHERE user_id = '#{user_id}'").values
        db.close            
       user_pto.flatten.first
end

# func that sends email for user that has no pto days
def email_for_no_pto(full_name, pto) 
    Mail.defaults do
        delivery_method :smtp,
        address: "email-smtp.us-east-1.amazonaws.com",
        port: 587,
        :user_name  => ENV['a3smtpuser'],
        :password   => ENV['a3smtppass'],
        :enable_ssl => true
      end
        email_body = "#{full_name[0]} #{full_name[1]} tried to request days and they have #{pto} day to request."
      mail = Mail.new do
          from         ENV['from']
          to           'billyjacktattoos@gmail.com'
          subject      "PTO Request with no days to request"
    
          html_part do
            content_type 'text/html'
            body       email_body
          end
      end
      mail.deliver!
    end