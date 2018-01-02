require 'rubyXL'


def get_template(temp)
    workbook = RubyXL::Parser.parse("./public/template/" + temp + '.xlsx')
    worksheet= workbook[0]
    worksheet.each { |row|
   row && row.cells.each { |cell|
     val = "#{cell} && #{cell.value}"
     p val
   }
}   
end

get_template("template")
