require 'rubyXL'

class InvoiceSpreadsheet

    def initialize()
    workbook = RubyXL::Parser.parse("./public/template/template.xlsx")
    @worksheet = workbook[0]
    end

    def input_data(location,input)
    loc = RubyXL::Reference.ref2ind(location)
    # p "#{x[loc[0]][loc[1]].value} before"
    @worksheet[loc[0]][loc[1]].change_contents(input, @worksheet[loc[0]][loc[1]].formula)
    # p "#{x[loc[0]][loc[1]].value} after"
    end

    def show_data(location)
        loc = RubyXL::Reference.ref2ind(location)
        p @worksheet[loc[0]][loc[1]]
        @worksheet[loc[0]][loc[1]]
    end
end


