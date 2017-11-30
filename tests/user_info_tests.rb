require "minitest/autorun"
require_relative '../user_id.rb'
load '../local_env.rb' if File.exist?('../local_env.rb')

class Test_funcs < Minitest::Test
    