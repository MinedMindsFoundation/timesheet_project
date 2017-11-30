require "minitest/autorun"
require_relative 'user_id.rb'
load 'local_env.rb' if File.exist?('local_env.rb')

class Test_funcs < Minitest::Test
    def test_get_user_info
        user_info = User.new("scottid")
        assert_equal(["scottid","Scott","Stewart","No","1"],user_info.user_data)
    end
end