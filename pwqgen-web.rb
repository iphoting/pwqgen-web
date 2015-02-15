require 'rubygems'
require 'bundler/setup'

require 'rack'

require 'rdiscount'
require 'haml'
require 'sinatra'
require 'sinatra/namespace'

require 'rack-timeout'
require 'sys/uname'
require 'pwqgen'

configure :production do
	require 'newrelic_rpm' if ENV["NEW_RELIC_LICENSE_KEY"] and ENV["NEW_RELIC_APP_NAME"]
	require 'rack/ssl-enforcer'
	use Rack::SslEnforcer, :hsts => true
end

use Rack::Timeout
Rack::Timeout.timeout = 10
use Rack::ConditionalGet
use Rack::ETag
use Rack::ContentLength
use Rack::Deflater

namespace %r{\/m(?:ulti)?\/?} do
	get %r{\/te?xt(?:\/([\d]+))?\/?} do |d|
		content_type 'text/plain'
		count = (d.nil?)? 30 : d.to_i
		gen_n_pass(count)
	end

	get %r{(?:\/([\d]+)\/?)?} do |d|
		@count = (d.nil?)? 30 : d.to_i
		@passwords = gen_n_pass(@count)
		haml :multi
	end
end

namespace '/pin' do
	get '/txt/?:num?' do
		n = (params[:num].to_i <= 0 || params[:num].to_i > 2048)? 6 : params[:num].to_i
		content_type 'text/plain'
		gen_pin(n)
	end

	get '/:num/txt' do
		n = (params[:num].to_i <= 0 || params[:num].to_i > 2048)? 6 : params[:num].to_i
		content_type 'text/plain'
		gen_pin(n)
	end

	get '/?:num?' do
		n = (params[:num].to_i <= 0 || params[:num].to_i > 2048)? 6 : params[:num].to_i
		@password = gen_pin(n)
		haml :index
	end
end

get %r{\/te?xt} do
	content_type 'text/plain'
	gen_pass
end

get '/' do
	@password = gen_pass
	haml :index
end

def gen_pin(n = 6)
	require 'securerandom'
	output = ""
	for i in 1..n do
		output += SecureRandom.random_number(10).to_s
	end
	return output
end

def gen_n_pass(count = 30)
	count.times.collect do |i|
		gen_pass
	end.join($/) # join with newlines.
end

def gen_pass
	if Sys::Uname.sysname.to_s.downcase.include? "linux" then
		`./pwqgen.static`.chomp
	else
		Pwqgen.generate
	end
end
