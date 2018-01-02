require 'rubyXL'

class InvoiceSpreadsheet

    def initialize() # parses invoice template on startups and sets first worksheet to an instance variable
    workbook = RubyXL::Parser.parse("./public/template/template.xlsx")
    @worksheet = workbook[0]
    end

    def input_data(location,input) # Changes the value of the cell(location) to input
    loc = RubyXL::Reference.ref2ind(location)
    # p "#{x[loc[0]][loc[1]].value} before"
    @worksheet[loc[0]][loc[1]].change_contents(input, @worksheet[loc[0]][loc[1]].formula)
    # p "#{x[loc[0]][loc[1]].value} after"
    end

    def show_data(location) # Returns the value of the cell selected
        loc = RubyXL::Reference.ref2ind(location)
        p @worksheet[loc[0]][loc[1]].value
        @worksheet[loc[0]][loc[1]].value
    end
end


