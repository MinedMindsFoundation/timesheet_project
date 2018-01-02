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

    def test_accession_template_2
        x = InvoiceSpreadsheet.new()
        assert_equal("Name:",x.show_data("B4"))
    end
end