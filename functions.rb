require 'date'
require "time"
require 'pg'
require 'net/smtp'
require 'mail'
load './local_env.rb' if File.exist?('./local_env.rb')

#gets date & time from system
def get_time()
    arr = []
    x = Time.now.utc + Time.zone_offset('EST')
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
def submit_time_in(user_id,location,time,date)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    # db.exec("UPDATE info SET  status= 'in' WHERE user_id = '#{user_id}'")
    db.exec("INSERT INTO timesheet_new(user_id,time_in,lunch_start,lunch_end,time_out,date,date_out,location)VALUES('#{user_id}','#{time}','N/A','N/A','N/A','#{date}','#{date}','#{location}')")
    db.close
end

#submits time out to timesheet table
def submit_time_out(user_id,time,date)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
        # db.exec("UPDATE info SET  status= 'out' WHERE user_id = '#{user_id}'")
        db.exec("UPDATE timesheet_new SET time_out = '#{time}', date_out = '#{date}' WHERE user_id = '#{user_id}' AND time_out = 'N/A'")
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
    db.exec("insert into pto(user_id,pto)VALUES('#{user_id}','#{pto}')")
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
    user_checked << db.exec("SELECT time_in, date FROM timesheet_new WHERE time_out = 'N/A' AND user_id = '#{user_id[0]}'").values.flatten
    user_checked << db.exec("SELECT location FROM timesheet_new WHERE time_out = 'N/A' and user_id = '#{user_id[0]}'").values.flatten.first
    end
    db.close
    next_checked = user_checked.flatten
    next_checked.each_slice(5)
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
    db.close
    users.each do |user|
        data << user
    end
    data
end

def emp_info(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    data = []
    emails = db.exec("SELECT email FROM email WHERE user_id = '#{user_id}'").values
    admins = db.exec("SELECT admin FROM admin_status WHERE user_id = '#{user_id}'").values
    users = db.exec("SELECT user_id, first_name, last_name, date_of_hire FROM info_new WHERE user_id = '#{user_id}'").values
    pto_time = db.exec("SELECT pto FROM pto WHERE user_id = '#{user_id}'").values
    db.close
    users.each do |user|
        data << user
    end
    emails.first.each do |email|
        data << email
    end
    admins.each do |admin|
        data << admin.flatten
    end
    pto_time.each do |pto|
        data << pto.flatten
    end
    data.flatten
end

def update_user(user_id, new_info)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    db.exec("UPDATE info_new SET user_id = '#{new_info[0]}' ,first_name = '#{new_info[1]}' ,last_name = '#{new_info[2]}' ,date_of_hire = '#{new_info[3]}' WHERE user_id = '#{user_id}'")
    db.exec("UPDATE email SET email = '#{new_info[4]}' WHERE user_id = '#{user_id}'")
    db.exec("UPDATE admin_status SET admin = '#{new_info[5]}' WHERE user_id = '#{user_id}'")
    db.exec("UPDATE pto SET pto = '#{new_info[6]}' WHERE user_id = '#{user_id}'")
    db.close
end

def delete_emp(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    db.exec("DELETE FROM email WHERE user_id = '#{user_id}'")
    db.exec("DELETE FROM info_new WHERE user_id = '#{user_id}'")
    db.exec("DELETE FROM admin_status WHERE user_id = '#{user_id}'")
    db.exec("DELETE FROM pto WHERE user_id = '#{user_id}'")
    db.exec("DELETE FROM timesheet_new WHERE user_id = '#{user_id}'")
    db.close
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
    email_body = "#{full_name[0]} #{full_name[1]} is requesting thes dates #{start_vec} to #{end_vac}. They have #{pto}PTO days left to request. <a href= 'http://localhost:4567'> To Reply Click Here . </a>"
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
    #  user_id
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
        email_body = "#{full_name[0]} #{full_name[1]} tried to request days and they have #{pto}PTO days left to request.<a href= 'http://localhost:4567'> To Reply Click Here . </a>"
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

def ssologin_check?(username,password)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
    a = db.exec("SELECT pass FROM pass WHERE user_id = '#{username}'")
    db.close
    p "#{a.values.first.first} looooooook hererererererer"
    if a.num_tuples.zero? == false
        if password == a.values.flatten.first
            true
        else
            false
        end        
    else
        false
    end        
end

def live_time(start_time, end_time)
    s = Time.parse(start_time)
    e = Time.parse(end_time)
    minutes = (e - s)/60
    hours = 0
    days = 0
    if minutes >= 60
        hours = minutes/60
        minutes = minutes % 60
        if hours >= 24
            days = hours/24
            hours = hours % 24
        end
    end
[days.to_i,hours.to_i,minutes.to_i]    
end


def time_date_fix(user_id,date)
    db_params = {
    host: ENV['host'],
    port: ENV['port'],
    dbname: ENV['dbname'],
    user: ENV['user'],
    password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    data = []
    fixer_date =db.exec("SELECT time_in, lunch_start, lunch_end, time_out, date, date_out, location FROM timesheet_new WHERE user_id = '#{user_id}' AND date = '#{date}'").values
    db.close
    fixer_date.each do |item|
        data << item
    end
    data
end

def timetable_fix(user_id, date, time_in, new_time)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
    db = PG::Connection.new(db_params)
    db.exec("UPDATE timesheet_new SET time_in = '#{new_time[0]}', lunch_start = '#{new_time[1]}', lunch_end = '#{new_time[1]}', time_out = '#{new_time[3]}', date = '#{new_time[4]}', date_out = '#{new_time[5]}', location='#{new_time[6]}' WHERE user_id='#{user_id}' AND date = '#{date}' AND time_in = '#{time_in}'")
    db.close
end

def timetable_delete(user_id, date, time_in)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
    db = PG::Connection.new(db_params)
    db.exec("DELETE FROM timesheet_new WHERE user_id='#{user_id}' AND date = '#{date}' AND time_in = '#{time_in}'")
    db.close
end

def  pto_request_db_add(user_id,start_date,end_date)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    db.exec("INSERT INTO pto_requests(user_id,start_date,end_date,approval)VALUES('#{user_id}','#{start_date}','#{end_date}','pending')")
end

def send_email_for_pto_request_approvel(start_vec, end_vac, full_name, pto) 
    Mail.defaults do
        delivery_method :smtp,
        address: "email-smtp.us-east-1.amazonaws.com",
        port: 587,
        :user_name  => ENV['a3smtpuser'],
        :password   => ENV['a3smtppass'],
        :enable_ssl => true
      end
        email_body = "#{full_name[0]} #{full_name[1]}your PTO request was approved for the following days #{start_vec} to #{end_vac}. you have #{pto}PTO days left to request. Enjoy you time off."
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

    def send_email_for_pto_request_denial(start_vec, end_vac, full_name, pto) 
        Mail.defaults do
            delivery_method :smtp,
            address: "email-smtp.us-east-1.amazonaws.com",
            port: 587,
            :user_name  => ENV['a3smtpuser'],
            :password   => ENV['a3smtppass'],
            :enable_ssl => true
          end
          mail = Mail.new do
            email_body = "#{full_name[0]} #{full_name[1]}your PTO request was denied the following days #{start_vec} to #{end_vac}. you have #{pto}PTO days left to request."
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
         
    
def pull_pto_request()
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    pto_request = db.exec("SELECT user_id,start_date,end_date FROM pto_requests").values
    pto_request.each do |requests|
        names = database_info(requests[0])
        requests[0] = "#{names[0]} #{names[1]}"
    end
    pto_request
end

def send_email_for_adding_a_new_user(fullname, email) 
    Mail.defaults do
        delivery_method :smtp,
        address: "email-smtp.us-east-1.amazonaws.com",
        port: 587,
        :user_name  => ENV['a3smtpuser'],
        :password   => ENV['a3smtppass'],
        :enable_ssl => true
      end
        email_body = "#{fullname[0]} #{fullname[1]} you have just been added to our team, Welcome.<a href= 'http://localhost:4567'> Click Here . </a>"
      mail = Mail.new do
          from         ENV['from']
          to           email
          subject      "PTO Request"
    
          html_part do
            content_type 'text/html'
            body       email_body
          end
      end
      mail.deliver!
    end
