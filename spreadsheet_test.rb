require "minitest/autorun"
require_relative 'spreadsheet.rb'

class Test_spreadsheet < Minitest::Test
    
    def test_1_and_1
        assert_equal(1,1)
    end

    def test_accessing_template_1
        x = InvoiceSpreadsheet.new()
        assert_equal("Description",x.show_data("C7"))
    end

    def test_accessing_template_2
        x = InvoiceSpreadsheet.new()
        assert_equal("Name:",x.show_data("B4"))
    end

    def test_accessing_template_3
        x = InvoiceSpreadsheet.new()
        assert_equal("WEEK COMMENCING:",x.show_data("E4"))
    end

    def test_accessing_template_4_return_nil
        x = InvoiceSpreadsheet.new()
        assert_nil(x.show_data("A1"))
    end

    def test_input_data
        input = 12
        loc = "A1"
        x = InvoiceSpreadsheet.new()
        x.input_data(loc,input)
        assert_equal(input,x.show_data(loc))
    end

    def test_input_data_a1_is_12
        input = 12
        loc = "A1"
        x = InvoiceSpreadsheet.new()
        x.input_data(loc,input)
        assert_equal(input,x.show_data(loc))
    end


    def test_input_data_a1_is_word
        input = "word"
        loc = "A1"
        x = InvoiceSpreadsheet.new()
        x.input_data(loc,input)
        assert_equal(input,x.show_data(loc))
    end


    def test_input_data_c4_is_32_string
        input = "32"
        loc = "C4"
        x = InvoiceSpreadsheet.new()
        x.input_data(loc,input)
        assert_equal(input,x.show_data(loc))
    end

    # def test_for_generating_new_file
    #     x = InvoiceSpreadsheet.new()
    #     x.input_data("A1","NEW FILE TEST")
    #     x.generate_new_file("TEST","1-1-2018")
    #     p "it ran"
    #     x.delete_file("TEST","1-1-2018")
    # end


    # def test_for_mail_invoice
    #     x = InvoiceSpreadsheet.new()
    #     x.input_data("A1","TEST WOO")
    #     x.mail_invoice("TEST@test.com", "TEST","1-1-2018")
    #     p "it did it"
    # end

end