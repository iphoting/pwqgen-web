require 'capybara/cucumber'
require "#{File.dirname(File.dirname(File.dirname(__FILE__)))}/pwqgen-web"

Capybara.app = Sinatra::Application.new
