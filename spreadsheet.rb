require 'rubyXL'
require "mail"
load './local_env.rb' if File.exist?('./local_env.rb')
class InvoiceSpreadsheet

    def initialize() # parses invoice template on startups and sets first worksheet to an instance variable
    @workbook = RubyXL::Parser.parse("./public/template/template.xlsx")
    @worksheet = @workbook[0]
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

    def generate_new_file(name,date)
        @workbook.write(name + " " + date + " " + "invoice.xlsx")
    end

    def delete_file(name,date)
       File.delete(name + " " + date + " " + "invoice.xlsx")
    end

    def mail_invoice(to_email,name,date)
        generate_new_file(name,date)
        path = File.absolute_path(name + " " + date + " " + "invoice.xlsx")
        p path
        Mail.defaults do
            delivery_method :smtp,
            address: "email-smtp.us-east-1.amazonaws.com",
            port: 587,
            :user_name  => ENV['a3smtpuser'],
            :password   => ENV['a3smtppass'],
            :enable_ssl => true
          end
            email_body = "#{name} invoice" 
                mail = Mail.new do
                from         ENV['from']
                to           'scottmstewart2@gmail.com'
                subject      "PTO Request with no days to request"
                add_file path
        
            html_part do
                content_type 'text/html'
                body       email_body
            end
        end
          mail.deliver!

         delete_file(name,date)
    end

end


