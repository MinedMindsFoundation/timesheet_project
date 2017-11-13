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

        def test_get_time_return_type
            x = get_time().class
            assert_equal(Array,x)
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
            x = database_info('TESTID')
            assert_equal(["TEST","TEST"],x)
        end

        def test_datebase_info_names_2
            x = database_info('TESTID').length
            assert_equal(2,x)
        end

        def test_database_return_type
            x = database_info('TESTID').class
            assert_equal(Array,x)
        end

    #<----test for pull_in_and_out_time()---->
        def test_pull_in_and_out_returns_array
            x = pull_in_and_out_times("TESTID",pay_period(Time.new(2017,10,31,0,0,0)))
            assert_equal(Array,x.class)
        end

    #<----test for live time ---->
        def test_live_time_hour
            x = live_time("03:00 2017-10-10","04:00 2017-10-10")
            assert_equal([0,1,0],x)
        end

        def test_live_time_20_minutes
            x = live_time("03:00 2017-10-10","03:20 2017-10-10")
            assert_equal([0,0,20],x)
        end

        def test_live_time_1_day
            x = live_time("03:00 2017-10-10","03:00 2017-10-11")
            assert_equal([1,0,0],x)
        end

        def test_live_time_1_d_2_h_47_m
            x = live_time("03:00 2017-10-10","05:47 2017-10-11")
            assert_equal([1,2,47],x)
        end

        def test_live_time_2_d_23_h_59_m
            x = live_time("03:00 2017-10-10","02:59 2017-10-13")
            assert_equal([2,23,59],x)
        end

    #<!---Vacation time tests--->
        def test_vac_time_1
            x = vac_time().class
            assert_equal(String,x)
        end   
        
        def test_vac_time_2
            x = vac_time().class
            assert_equal(String,x)
        end    

        def test_vac_time_length_1
            x = vac_time().length
            assert_equal(10,x)
        end    

        def test_vac_time_length_2
            x = vac_time().length
            assert_equal(10,x)
        end    

    #<!---submit time in section--->
        # def test_time_in_1
        #     submit_time_in(user_id,location,time,date)
        #     x = time_in_check?(user_id)    

    
end