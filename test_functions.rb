require "minitest/autorun"
require_relative 'functions.rb'

class Test_funcs < Minitest::Test
    
    def test_1_and_1
        assert_equal(1,1)
    end

    # def test_login
    #     x = login_check?('test@email.com')
    #     assert_equal(x,true)
    # end

    def test_login_false
        x = login_check?('no_email@email.com')
        assert_equal(x,false)
    end

    def test_get_time
        x = get_time().length
        assert_equal(x,2)
    end

    def test_payperiod_first
        x = pay_period(Time.new(2017,10,31,15,42))
        y = ["2017-10-30","2017-11-12"]
        assert_equal(x,y)
    end

    def test_payperiod_second
        x = pay_period(Time.new(2017,11,16,))
        y = ["2017-11-13","2017-11-26"]
        p x
        p y
        assert_equal(x,y)
    end
end