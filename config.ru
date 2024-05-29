
map '/assets' do
	require 'sprockets'
	environment = Sprockets::Environment.new
	environment.append_path '_assets/js'
	environment.js_compressor = :uglify
	run environment
end

map '/' do
	require "#{File.dirname(__FILE__)}/pwqgen-web"
	run Sinatra::Application
end

