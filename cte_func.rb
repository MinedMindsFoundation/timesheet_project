require 'pg'
load 'local_env.rb' if File.exist?('local_env.rb')

def get_supervises(user_id)
    db_params = {
        host: ENV['host'],
        port: ENV['port'],
        dbname: ENV['dbname'],
        user: ENV['user'],
        password: ENV['password']
    }
    db = PG::Connection.new(db_params)

    users = db.exec("WITH RECURSIVE search_graph(user_id,supervisor, depth) AS (
        SELECT g.user_id, g.supervisor, 0
        FROM supervisor g
        WHERE supervisor = 'top' 
      UNION ALL
        SELECT g.user_id, g.supervisor,  sg.depth + 1
        FROM supervisor g, search_graph sg
        WHERE  g.supervisor = sg.user_id
)
SELECT * FROM search_graph;")

    last_num = users.values.last.last.to_i
    db.close
    num = ""
    arr = []
    arr_2 = []
    counter = 0
    users.values.each do |id|
        if id[0] == user_id
            num = id[2].to_i
        end
    end
    users.values.each do |id|
        if id[2].to_i > num && user_id == id[1]
            
            arr << id[0]
             arr
            arr_2 << id[0]
        end
    end
    until arr.empty?
        item = arr.pop
        users.values.each do |id|
            if id[2].to_i > num && item == id[1]
                arr << id[0]
                arr_2 << id[0]
            end
        end
    end
    arr_2
end

