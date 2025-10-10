require 'capybara/cucumber'
require "#{File.dirname(File.dirname(File.dirname(__FILE__)))}/pwqgen-web"

set :host_authorization, permitted_hosts: []

Capybara.app = Sinatra::Application.new
