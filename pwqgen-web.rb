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

require 'rack/ssl-enforcer'
use Rack::SslEnforcer, :hsts => true, :only_environments => 'production'

use Rack::Timeout, service_timeout: 10
use Rack::ConditionalGet
use Rack::ETag
use Rack::ContentLength
use Rack::Deflater

before do
	@classic = request.host == "pwqgen.herokuapp.com" and Sys::Uname.sysname.to_s.downcase.include? "linux"
end

namespace %r{\/m(?:ulti)?\/?} do
	get %r{\/te?xt(?:\/([\d]+))?\/?} do |d|
		content_type 'text/plain'
		count = (d.nil?)? 30 : d.to_i
		if @classic
			gen_n_pass_classic(count)
		else
			gen_n_pass(count)
		end
	end

	get %r{(?:\/([\d]+)\/?)?} do |d|
		@count = (d.nil?)? 30 : d.to_i
		@passwords = (@classic)? gen_n_pass_classic(@count) : gen_n_pass(@count)
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

namespace '/hex' do
	get '/txt/?:num?' do
		n = (params[:num].to_i <= 0 || params[:num].to_i > 4096)? 256 : params[:num].to_i
		content_type 'text/plain'
		gen_hex(n)
	end

	get '/:num/txt' do
		n = (params[:num].to_i <= 0 || params[:num].to_i > 4096)? 256 : params[:num].to_i
		content_type 'text/plain'
		gen_hex(n)
	end

	get '/?:num?' do
		n = (params[:num].to_i <= 0 || params[:num].to_i > 4096)? 256 : params[:num].to_i
		@password = gen_hex(n)
		haml :index
	end
end

get %r{\/te?xt} do
	content_type 'text/plain'
	if @classic
		gen_pass_classic
	else
		gen_pass
	end
end

get '/' do
	@password = (@classic)? gen_pass_classic : gen_pass
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

def gen_hex(n = 256)
	require 'securerandom'
	SecureRandom.hex(n / 8)
end

# Modern behaviour based on pwqgen.rb
def gen_n_pass(count = 30)
	count.times.collect do |i|
		gen_pass
	end.join($/) # join with newlines.
end

def gen_pass
		Pwqgen.generate
end

# Original behaviour
def gen_n_pass_classic(count = 30)
	count.times.collect do |i|
		gen_pass_classic
	end.join($/) # join with newlines.
end

def gen_pass_classic
	if Sys::Uname.sysname.to_s.downcase.include? "linux" then
		`./pwqgen.static`.chomp
	else
		gen_pass
	end
end
