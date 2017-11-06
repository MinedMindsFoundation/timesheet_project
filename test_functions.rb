require "minitest/autorun"
require_relative 'functions.rb'

class Test_funcs < Minitest::Test
    
    def test_1_and_1
        assert_equal(1,1)
    end
    # <---tests for login---->

        # def test_login
        #     x = login_check?('test@email.com')
        #     assert_equal(x,true)
        # end

        def test_login_false
            x = login_check?('no_email@email.com')
            assert_equal(x,false)
        end
    # <---test for get time---->
    
        def test_get_time
            x = get_time().length
            assert_equal(x,2)
        end
    # <----tests_for_pay_period()----> 

        def test_payperiod_first
            x = pay_period(Time.new(2017,10,31,15,42))
            y = ["2017-10-30","2017-11-12"]
            assert_equal(y,x)
        end

        def test_payperiod_second
            x = pay_period(Time.new(2017,11,16,))
            y = ["2017-11-13","2017-11-26"]
            assert_equal(y,x)
        end

        def test_payperiod_latest_possible_time
            x = pay_period(Time.new(2017,11,26,13,59,59))
            y = ["2017-11-13","2017-11-26"]
            assert_equal(y,x)
        end

        def test_payperiod_Earliest_possible_time
            x = pay_period(Time.new(2017,11,13,0,0,0))
            y = ["2017-11-13","2017-11-26"]
            assert_equal(y,x)
        end

    # <---tests for time_converter--->

        def test_time_converter
            x = time_converter("02:08")
            y = "02:08 am"
            assert_equal(y,x)
        end

        def test_time_converter_2234
            x = time_converter("22:34")
            y = "10:34 pm"
            assert_equal(y,x)
        end

        def test_time_converter_0012
            x = time_converter("00:12")
            y = "12:12 am"
            assert_equal(y,x)
        end

    # <----tests for who is clocked in----> 

        def test_who_is_clocked_in_multi_d_array
            x = who_is_clocked_in()
            assert_equal(2,x.count)
        end

        def test_who_is_clocked_in_return_type()
            x = who_is_clocked_in()
            assert_equal(Array,x.class)
        end 
        
    # <----test for database_info()---->
        
        def test_database_info_whats_returned
            x = database_info('TestID')
            assert_equal(["TEST","TEST"],x)
        end
end