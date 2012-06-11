require 'rubygems'
require 'bundler'
Bundler.setup(:default, ENV['RACK_ENV'])

require 'sinatra'
require 'haml'

get %r{/te?xt} do
	`pwqgen`
end

get '/' do
	haml :index
end

