require 'date'
require "time"
require 'pg'
require 'net/smtp'
require 'mail'
require 'googleauth'
require 'google/apis/calendar_v3'
require_relative "g_calendar"

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
    db.close
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

def user_hierarchy(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    user_h = db.exec("SELECT hierarchy FROM admin_status WHERE user_id = '#{user_id}'").values.flatten
    db.close
    user_h[0]
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
def add_user(user_id,email,first_name,last_name,pto,supervisor,admin_access,doh,department,job,vacation,sick)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    db.exec("insert into info_new(user_id,first_name,last_name)VALUES('#{user_id}','#{first_name}','#{last_name}')")
    db.exec("insert into pto(user_id,pto,vacation,sick)VALUES('#{user_id}','#{pto}','#{vacation}','#{sick}')")
    db.exec("insert into admin_status(user_id,admin)VALUES('#{user_id}','#{admin_access}')")
    db.exec("INSERT into supervisor(user_id,supervisor)VALUES('#{user_id}','#{supervisor}')")
    db.exec("insert into email(user_id,email)VALUES('#{user_id}','#{email}')")
    db.exec("insert into title_and_doh(user_id,date_of_hire,job_title,department)VALUES('#{user_id}','#{doh}','#{job}','#{department}')")
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
    next_checked.each_slice(5).to_a
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
    users = db.exec("SELECT user_id, first_name, last_name FROM info_new WHERE user_id = '#{user_id}'").values
    emails = db.exec("SELECT email FROM email WHERE user_id = '#{user_id}'").values
    admins = db.exec("SELECT admin FROM admin_status WHERE user_id = '#{user_id}'").values
    supervisor = db.exec("SELECT supervisor FROM supervisor WHERE user_id = '#{user_id}'").values
    pto_time = db.exec("SELECT pto, vacation, sick FROM pto WHERE user_id = '#{user_id}'").values
    doh_and_job = db.exec("SELECT date_of_hire, job_title, department FROM title_and_doh WHERE user_id = '#{user_id}'").values
    db.close
    users.each do |user|
        data << user
        # p "#{user} user"
    end
    emails.first.each do |email|
        data << email
        # p "#{email} email"
    end
    pto_time.each do |pto|
        data << pto.flatten
        # p "#{pto} pto"
    end
    doh_and_job.each do |item|
        data << item
        # p "#{item} item"
    end
    admins.each do |admin|
        data << admin.flatten
        # p "#{admin} admin"
    end
    supervisor.each do |supervisors|
        data << supervisors
        # p "#{supervisors} supervisors" 
    end
    # p data
    data.flatten
end

def add_title_doh_department(user_id,doh,job,department)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    db.exec("insert into title_and_doh(user_id,date_of_hire,job_title,department)VALUES('#{user_id}','#{doh}','#{job}','#{department}')")
    db.close
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
    db.exec("UPDATE info_new SET user_id = '#{new_info[0]}' ,first_name = '#{new_info[1]}' ,last_name = '#{new_info[2]}' WHERE user_id = '#{user_id}'")
    db.exec("UPDATE email SET email = '#{new_info[3]}' WHERE user_id = '#{user_id}'")
    db.exec("UPDATE pto SET pto = '#{new_info[4]}', vacation = '#{new_info[5]}', sick = '#{new_info[6]}' WHERE user_id = '#{user_id}'")
    db.exec("UPDATE title_and_doh SET date_of_hire = '#{new_info[7]}', job_title = '#{new_info[8]}', department = '#{new_info[9]}' WHERE user_id = '#{user_id}'")
    db.exec("UPDATE admin_status SET admin ='#{new_info[10]}' WHERE user_id = '#{user_id}'")
    db.exec("UPDATE supervisor SET supervisor = '#{new_info[11]}' WHERE user_id = '#{user_id}'")
    db.close
end

def remove_emp(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    db.exec("UPDATE admin_status  SET admin= 'removed' WHERE user_id = '#{user_id}'")
    supervisor = db.exec("SELECT supervisor FROM  supervisor WHERE user_id = '#{user_id}'").values.flatten.first
    db.exec("UPDATE supervisor SET supervisor='#{supervisor}' WHERE supervisor = '#{user_id}'")
    db.exec("UPDATE supervisor SET supervisor='removed' WHERE user_id = '#{user_id}'")
    db.close
end

def status_check(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    status = db.exec("SELECT admin FROM admin_status WHERE user_id = '#{user_id}'").values.flatten.first
    db.close
    status
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
    db.exec("DELETE FROM title_and_doh WHERE user_id = '#{user_id}'")
    db.exec("DELETE FROM timesheet_new WHERE user_id = '#{user_id}'")
    db.exec("DELETE FROM supervisor WHERE user_id = '#{user_id}'")
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

def two_week_days(now)
    add_2weeks = (14 * 60 * 60 * 24)
    endday = (13 * 60 * 60 * 24)  + (23 * 60 *60 ) +(59*60) + 59

    start_date = Time.utc(2017,10,30)
    end_date = start_date + endday
        until now < end_date do
            start_date += add_2weeks   
            end_date = start_date + endday
        end
    arr = []
        14.times do
            # p start_date
            arr << start_date.strftime('%Y-%m-%d')
            start_date += (60 * 60 * 24)
        end
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

def send_email(start_vec, end_vac, full_name, pto, type) 
Mail.defaults do
    delivery_method :smtp,
    address: "email-smtp.us-east-1.amazonaws.com",
    port: 587,
    :user_name  => ENV['a3smtpuser'],
    :password   => ENV['a3smtppass'],
    :enable_ssl => true
  end
    email_body = "#{full_name[0]} #{full_name[1]} is requesting #{type} for these dates #{start_vec} to #{end_vac}. They have #{pto}PTO days left to request. <a href= 'https://wv-timesheet-clock.herokuapp.com/vac_time_request'> To Reply Click Here . </a>"
  mail = Mail.new do
      from         ENV['from']
      to           'wvtimeclockdev@gmail.com'
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
            arr_in << "#{name[0].capitalize} #{name[1].capitalize}"
        else
            arr_out << "#{name[0].capitalize} #{name[1].capitalize}"
        end
    end
    db.close
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

#func for getting vac time
def get_vacation_time(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
        user_vac = db.exec("SELECT vacation FROM pto WHERE user_id = '#{user_id}'").values
        db.close            
       user_vac.flatten.first
end
#func for getting sic time

def sic_time(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
        user_sic = db.exec("SELECT sick FROM pto WHERE user_id = '#{user_id}'").values
        db.close            
       user_sic.flatten.first
end

# func that sends email for user that has no pto days
def email_for_no_pto(full_name, pto, pto_type) 
    Mail.defaults do
        delivery_method :smtp,
        address: "email-smtp.us-east-1.amazonaws.com",
        port: 587,
        :user_name  => ENV['a3smtpuser'],
        :password   => ENV['a3smtppass'],
        :enable_ssl => true
      end
        email_body = "#{full_name[0]} #{full_name[1]} tried to request #{pto_type}and they have #{pto}PTO days left to request.<a href= 'https://wv-timesheet-clock.herokuapp.com/'> To Reply Click Here . </a>"
      mail = Mail.new do
          from         ENV['from']
          to           'wvtimeclockdev@gmail.com'
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
    db.exec("UPDATE timesheet_new SET time_in = '#{new_time[0]}', lunch_start = '#{new_time[1]}', lunch_end = '#{new_time[2]}', time_out = '#{new_time[3]}', date = '#{new_time[4]}', date_out = '#{new_time[5]}', location='#{new_time[6]}' WHERE user_id='#{user_id}' AND date = '#{date}' AND time_in = '#{time_in}'")
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

def  pto_request_db_add(user_id,start_date,end_date,type)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    db.exec("INSERT INTO pto_requests(user_id,start_date,end_date,approval,type_of_days)VALUES('#{user_id}','#{start_date}','#{end_date}','pending','#{type}')")
    db.close
end

def send_email_for_pto_request_approval(start_vec, end_vac, full_name,email, pto, comment,pto_type) 
    Mail.defaults do
        delivery_method :smtp,
        address: "email-smtp.us-east-1.amazonaws.com",
        port: 587,
        :user_name  => ENV['a3smtpuser'],
        :password   => ENV['a3smtppass'],
        :enable_ssl => true
      end
        email_body = "#{full_name[0]} #{full_name[1]}your PTO request was approved for the following days #{start_vec} to #{end_vac}. you have #{pto} #{pto_type} days left to request. Please fill out this form <a href= 'https://wv-timesheet-clock.herokuapp.com/vac_time_request'> Click Here To Fill Out PTO Form.</a> Enjoy you time off.#{comment}"
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

def send_email_for_pto_request_denial(start_vec, end_vac, full_name,email,pto,comment, pto_type) 
Mail.defaults do
delivery_method :smtp,
address: "email-smtp.us-east-1.amazonaws.com",
port: 587,
:user_name  => ENV['a3smtpuser'],
:password   => ENV['a3smtppass'],
:enable_ssl => true
end
mail = Mail.new do
email_body = "#{full_name[0]} #{full_name[1]}your PTO request was denied the following days #{start_vec} to #{end_vac}. you have #{pto} #{pto_type} days left to request. the reson #{comment}"
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


def pull_pto_request()
db_params = {
host: ENV['host'],
port: ENV['port'],
dbname: ENV['dbname'],
user: ENV['user'],
password: ENV['password']
}
db = PG::Connection.new(db_params)
pto_request = db.exec("SELECT user_id,start_date,end_date,type_of_days FROM pto_requests WHERE approval = 'pending'").values
pto_request.each do |requests|
    names = database_info(requests[0])
    requests << "#{names[0]} #{names[1]}"
end
db.close
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
    email_body = "#{fullname[0]} #{fullname[1]} you have just been added to our team, Welcome.<a href= 'https://wv-timesheet-clock.herokuapp.com/'> Click Here to clock in. </a>"
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
        
    def  submit_pto_approval(approval)
        db_params = {
            host: ENV['host'],
            port: ENV['port'],
            dbname: ENV['dbname'],
            user: ENV['user'],
            password: ENV['password']
            }
            db = PG::Connection.new(db_params)

            # p "#{approval}"
        approval.each do |item|
        # p "#{item} item arr here"
            if item[5] != ""
                db.exec("UPDATE pto_requests SET approval = '#{item[5]}' WHERE user_id= '#{item[0]}' AND start_date= '#{item[1]}' AND end_date= '#{item[2]}' ")
                email = database_email_check(item[0])
                pto = db.exec("SELECT pto From pto WHERE user_id = '#{item[0]}'").values
                full_name = item[3].split(' ')
                if item[5] == 'approved'
                    calendar = GoogleCalendar.new
                    calendar.create_calendar_event("#{item[1]}","#{item[2]}",email,"#{item[3]}")
                    # p "#{item[1]}","#{item[2]}",email,"#{item[3]}"
                    send_email_for_pto_request_approval(item[1],item[2], full_name,email,pto,item[6])
                elsif item[5] == "denied"
                    send_email_for_pto_request_denial(item[1],item[2], full_name,email,pto,item[6]) 
                end
                #goes here luke------- this is where is subtacts days aproved
                page = "nope"
                if item[4] == "Pto"
                    # p "inside pto.........................................inside pto"
                    old_date = Date.parse("#{item[1]}")
                    new_date = Date.parse("#{item[2]}")
                    days_between = (new_date - old_date).to_i
                    old_pto = pto_time(item[0]).to_i
                    new_pto = old_pto - days_between
                    new_sick = ""
                    new_vacation = ""
                    update_pto_time(item[0],new_pto,new_vacation,new_sick,page)
                elsif item[4] == "Vacation"
                    # p "inside vacation..................................Inside vacation"
                    old_date = Date.parse("#{item[1]}")
                    new_date = Date.parse("#{item[2]}")
                    days_between = (new_date - old_date).to_i
                    old_pto = get_vacation_time(item[0]).to_i
                    new_vacation = old_pto - days_between
                    new_pto = ""
                    new_sick = ""
                    update_pto_time(item[0],new_pto,new_vacation,new_sick,page)
                elsif item[4] == "Sick"
                    # p "inside sick.............................................inside sick"
                    old_date = Date.parse("#{item[1]}")
                    new_date = Date.parse("#{item[2]}")
                    days_between = (new_date - old_date).to_i
                    old_pto = sic_time(item[0]).to_i
                    new_sick = old_pto - days_between
                    new_pto = ""
                    new_vacation = ""
                    update_pto_time(item[0],new_pto,new_vacation,new_sick,page)
                end
            end    
        end
        db.close
    end

def get_users_pto_request(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
        user_pto = db.exec("SELECT start_date,end_date,approval FROM pto_requests WHERE user_id = '#{user_id}'").values
        db.close
    user_pto
end


# <--returns false if user has started lunch but hasnt ended it yet-->
def time_out_lunch_check?(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
    check = db.exec("SELECT * FROM timesheet_new WHERE user_id = '#{user_id}' AND lunch_start != 'N/A' AND lunch_end = 'N/A' AND time_out = 'N/A' ")
    db.close    
    check.num_tuples.zero?
end

def time_zero_remove(time_arr)
    ret_string = ""
    if time_arr[0].to_s == "0"
    elsif time_arr[0].to_s == "1"
       ret_string = ret_string + " " + "#{time_arr[0]}" + " :day"
    else
        ret_string = ret_string + " " + "#{time_arr[0]}" + " :days"
    end

    if time_arr[1].to_s == "0"
    elsif time_arr[1].to_s == "1"
        ret_string = ret_string + " " + "#{time_arr[1]}" + " :hour"
    else
        ret_string = ret_string + " " + "#{time_arr[1]}" + " :hours"
    end

    if time_arr[2].to_s == "0"
    elsif time_arr[2].to_s == "1"
        ret_string = ret_string + " " + "#{time_arr[2]}" + " :minute"
    else
        ret_string = ret_string + " " + "#{time_arr[2]}" + " :minutes"
    end

    ret_string.strip!
    ret_string
end

#<!------ gets date of hire ------>
def pull_out_date_of_hire(userid)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
        hire_date = db.exec("SELECT date_of_hire FROM title_and_doh WHERE user_id = '#{userid}'").values
        db.close
    hire_date.flatten
end  

#<!-----------adds ptod time stamp ----------->
def pto_time_stamp(user_id)
    
    stamp = Time.now.strftime("%Y %m")
    db_params = {
    host: ENV['host'],
    port: ENV['port'],
    dbname: ENV['dbname'],
    user: ENV['user'],
    password: ENV['password']
    }
    db = PG::Connection.new(db_params)
    db.exec("UPDATE pto SET pto_time_stamp = '#{stamp}' WHERE user_id = '#{user_id}'")
    db.close

end    

#<!--------function for pulling back pto time stamp------>
def pull_pto_stamp(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
        }
        db = PG::Connection.new(db_params)
        check = db.exec("SELECT pto_time_stamp FROM pto WHERE user_id = '#{user_id}'").values
        db.close
    check.flatten
end        

#<!------ func for updating pto,Vacation,andSick time ------>
def update_pto_time(user_id,new_pto,new_vacation,new_sick,page)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
            }
        db = PG::Connection.new(db_params)
        if page == "hello"
            db.exec("UPDATE pto SET pto = '#{new_pto}' WHERE user_id = '#{user_id}'")
            db.exec("UPDATE pto SET vacation = '#{new_vacation}' WHERE user_id = '#{user_id}'")
            db.exec("UPDATE pto SET sick = '#{new_sick}' WHERE user_id = '#{user_id}'")
        else    
            if new_pto != ""
                p "....................PTO........................"
                db.exec("UPDATE pto SET pto = '#{new_pto}' WHERE user_id = '#{user_id}'")
            elsif new_vacation != ""  
                p "....................VAC........................"
                db.exec("UPDATE pto SET vacation = '#{new_vacation}' WHERE user_id = '#{user_id}'")
            elsif new_sick != ""  
                p "....................SIC........................"  
                db.exec("UPDATE pto SET sick = '#{new_sick}' WHERE user_id = '#{user_id}'")  
            end
        end    
        db.close            
end


#<!-- function for checking if pto needs added and adding it if it does -->
def timeoffbiuldup(user_id,user_info,user_pto,hire_date,pto_stamp,user_vac,user_sic,todays_year_stamp,todays_month_stamp)
    # d = Time.now.strftime("%Y")
    # c = Time.now.strftime("%m")  
    x = hire_date[0].split('-')
    s = pto_stamp[0].split(' ')
    if todays_year_stamp.to_i - x[0].to_i >= 2
        i = 2
        if s[0] != todays_year_stamp || s[1] != todays_month_stamp
            page = "hello"
            new_pto = user_pto.to_i + i
            new_vac = user_vac.to_i + i
            new_sic = user_sic.to_i + i
            update_pto_time(user_id,new_pto,new_vac,new_sic,page)
            pto_time_stamp(user_id)
            m = "days were added 2orlonger"
        else
            m = "days have already been added"
        end        
    else
        i = 1
        if s[0] != todays_year_stamp || s[1] != todays_month_stamp
            page = "hello"
            new_pto = user_pto.to_i + i
            new_vac = user_vac.to_i + i
            new_sic = user_sic.to_i + i
            update_pto_time(user_id,new_pto,new_vac,new_sic,page)
            pto_time_stamp(user_id)
            m = "days were added lessthat2"
        else
            m = "days have already been added"
        end
    end        
    m
end  

#time stamps for current day function area
def todays_year_stamp()
    d = Time.now.strftime("%Y")
    d
end
def todays_month_stamp()
    c = Time.now.strftime("%m") 
    c
end
  

def invoice_mail(email, name, start_date)
    Mail.defaults do
        delivery_method :smtp,
        address: "email-smtp.us-east-1.amazonaws.com",
        port: 587,
        :user_name  => ENV['a3smtpuser'],
        :password   => ENV['a3smtppass'],
        :enable_ssl => true
        end
        email_body = ""
        mail = Mail.new do
            from         ENV['from']
            to           email
            subject      "Invoice for #{name} from #{start_date}"
    
            html_part do
                content_type 'text/html'
                body       email_body
            end
        end
        mail.deliver!
end

#comment_filter removes all sets of comments that contain blanks
def comment_filter(comments)
    # p comments
    comments.each do |info|
    # p info
    # p info[1].values
        info[1].values.each do |item|
            if item.gsub(/\s+/, "") == ""
            comments.delete(info[0])
            end
        end
    end
    if comments.empty?
        "empty"
    else
        comments
    end
end

# makes comments into nested hash of client_name=>date=>[comment] 
def comment_reformat(comments)
    p comments
    info = {}
    comments.each_pair do |key,value|
        p "#{key},#{value}"
        if info[value['client']] == nil
            info={value['client']=>[{value['date'] => [value['comment']]}]}
        #    p "#{info={value['client']=>[{value['date'] => [value['comment']]}}} line 1 of conditional"
        elsif info[value['client']][value['date']] == nil
            info[value['client']] < {value['date'] => value["comment"]}
           p "#{info={value['client']=>{value['date'] => [value['comment']]}}} line 2 of conditional"
        else
            info[value['client']][value['date']].push(value['comment'])
        end 
    end
    p info
end