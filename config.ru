#!/usr/bin/env rakeup
#\ -E deployment

map '/assets' do
	require 'sprockets'
	environment = Sprockets::Environment.new
	run environment
end

map '/' do
	require "#{File.dirname(__FILE__)}/pwqgen-web"
	run Sinatra::Application
end

