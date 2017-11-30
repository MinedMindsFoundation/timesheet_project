require "minitest/autorun"
require_relative 'user_id.rb'
load 'local_env.rb' if File.exist?('local_env.rb')

class Test_funcs < Minitest::Test
    def test_get_user_info
        user_info = User.new("scottid")
        assert_equal(["scottid","Scott","Steward","No","1"],user_info.user_data)
    end

    def test_users_id
        user_info = User.new("scottid")
        p user_info.users_list
        assert_equal(Array,user_info.users_list.class)
    end

    def test_user_get_times
        user_info = User.new("scottid")
        p user_info.get_last_times
        assert_equal(Hash,user_info.get_last_times.class)
    end
end







