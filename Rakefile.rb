task :test do
	Dir[File.join(File.dirname(__FILE__), 'tests', '**' '*.rb')].each do |file|
    	ruby file
    end
end