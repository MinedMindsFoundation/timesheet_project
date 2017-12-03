require "minitest/autorun"
require_relative 'cte_func.rb'
load 'local_env.rb' if File.exist?('local_env.rb')

class Test_cte_funcs < Minitest::Test
    def test_assert_1_1
        assert_equal(1,1)
    end

    def test_get_supervisees_return_array
        user_id = "scottid"
        assert_equal(Array,get_supervisees(user_id).class)
    end

    def test_get_supervisees_return_arr_of_strings
        user_id = "scottid"
        assert_equal(String,get_supervisees(user_id).first.class)
    end

    def test_for_get_names_return_arr
        id_arr = ['scottid']
        assert_equal(Array,get_names(id_arr).class)
    end

    def test_get_names_return_multi_d_arr
        id_arr = ["scottid"]
        assert_equal(Array,get_names(id_arr).first.class)
    end

    def test_get_names_return_multi_d_arr_of_strings
        id_arr = ["scottid"]
        assert_equal(String,get_names(id_arr).flatten.first.class)
    end

    def test_get_names_return_specific_string
        id_arr = ["scottid"]
        assert_equal([["scottid", "Scott", "Steward"]],get_names(id_arr))
    end
end