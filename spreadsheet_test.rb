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

end