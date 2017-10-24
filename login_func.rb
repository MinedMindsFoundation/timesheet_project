require 'pg'
load './local_env.rb' if File.exist?('./local_env.rb')


def check_creds?(user,pass)
	db_params = {
	host: ENV['host'],
	port: ENV['port'],
	dbname: ENV['dbname'],
	user: ENV['user'],
	password: ENV['password']
}
db = PG::Connection.new(db_params)
 
check = db.exec("SELECT*FROM username_password WHERE user_name = '#{user}'")
 		if check.num_tuples.zero? == false
 			check_val = check.values.flatten
  			if check_val[1] == pass
 				true
 			else
 				false
 			end
 		else
 			false
 		end
end

def add_to_login(user,pass)
		db_params = {
	host: ENV['host'],
	port: ENV['port'],
	dbname: ENV['dbname'],
	user: ENV['user'],
	password: ENV['password']
}
db = PG::Connection.new(db_params)
 check = db.exec("SELECT*FROM username_password WHERE user_name = '#{user}'")
	message = ""
	if check.num_tuples.zero? == false
		message = "Username Already Taken"
	else
		message = "Login Created"
	db.exec("insert into username_password(user_name,pass_word)VALUES('#{user}','#{pass}')")
	end
	message
end

def hard_func(user, pass, admin)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
db = PG::Connection.new(db_params)
     
answer = ""
check = db.exec("SELECT * FROM username_password WHERE user_name = '#{user}'")

   if check.num_tuples.zero? == false
        answer = "Your Number is already being used"
    else
        answer = "you joined this phone book"
        db.exec("insert into username_password(user_name, pass_word, admin)VALUES('#{user}','#{pass}', '#{admin}')")
    end
    answer

end
hard_func("test", "1234", "no")
    