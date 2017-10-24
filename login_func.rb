def check_creds?(user,pass)
	db_params = {
	host: ENV['host'],
	port: ENV['port'],
	dbname: ENV['dbname'],
	user: ENV['user'],
	password: ENV['password']
}
db = PG::Connection.new(db_params)
 
check = db.exec("SELECT*FROM userandpassword WHERE username = '#{user}'")
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
 check = db.exec("SELECT*FROM userandpassword WHERE username = '#{user}'")
	message = ""
	if check.num_tuples.zero? == false
		message = "Username Already Taken"
	else
		message = "Login Created"
	db.exec("insert into userandpassword(username,password)VALUES('#{user}','#{pass}')")
	end
	message
end