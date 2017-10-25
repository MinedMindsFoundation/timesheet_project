require 'selenium-webdriver'
require 'test/unit'

load '../local_env.rb' if File.exist?('../local_env.rb')


class ThrivyTestCase < Test::Unit::TestCase

  def setup
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: { args: [ "--headless" ]})  
     @driver = Selenium::WebDriver.for:chrome, desired_capabilities:caps
    target_size = Selenium::WebDriver::Dimension.new(768, 894)
    @driver.manage.window.size = target_size
    @driver.navigate.to("http://wvtimeclock.herokuapp.com/")
    @wait = Selenium::WebDriver::Wait.new(:timeout => 15)
  end  

  def teardown
    @driver.close
  end

end