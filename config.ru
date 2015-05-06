#!/usr/bin/env rakeup
#\ -E deployment

map '/assets' do
	require 'sprockets'
	environment = Sprockets::Environment.new
	environment.append_path 'assets/js'
	environment.append_path 'assets/swf'
	run environment
end

map '/' do
	require "#{File.dirname(__FILE__)}/pwqgen-web"
	run Sinatra::Application
end

