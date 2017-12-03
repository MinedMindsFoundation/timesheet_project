require "minitest/autorun"
require_relative 'cte_func.rb'
load 'local_env.rb' if File.exist?('local_env.rb')

class Test_cte_funcs < Minitest::Test
    def test_assert_1_1
        assert_equal(1,1)
    end


end