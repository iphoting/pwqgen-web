#!/usr/bin/env rakeup
#\ -E deployment

map '/assets' do
	require 'sprockets'
	environment = Sprockets::Environment.new
	environment.append_path 'vendor/lib/ZeroClipboard/dist'
	environment.append_path 'assets/js'
	run environment
end

map '/' do
	require "#{File.dirname(__FILE__)}/pwqgen-web"
	run Sinatra::Application
end

