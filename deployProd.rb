options = {
    branch: "master",
    remote: "https://git.heroku.com/wv-timesheet-clock.git
    "
  }
  
  puts "----------------------------------------------------"
  puts "            Deploying Code to Heroku"
  puts "----------------------------------------------------"
  puts " Branch: #{options[:branch].upcase}"
  puts " Remote: #{options[:remote].upcase}"
  puts "----------------------------------------------------"
  
  system "heroku auth:login"
  system "git push -f #{options[:remote]} #{options[:branch]}:master"