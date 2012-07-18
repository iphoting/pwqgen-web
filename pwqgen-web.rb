require 'rubygems'
require 'bundler'
Bundler.setup(:default, ENV['RACK_ENV'])

require 'sinatra'
require 'haml'
require 'rack/ssl-enforcer'
require 'sys/uname'
require 'pwqgen'

configure :production do
	require 'newrelic_rpm'
	use Rack::SslEnforcer, :hsts => true
end

get %r{/te?xt} do
	content_type 'text/plain'
	gen_pass
end

get '/' do
	@password = gen_pass
	haml :index
end

def gen_pass
	if Sys::Uname.sysname.to_s.downcase.include? "linux" then
		`./pwqgen.static`
	else
		Pwqgen.generate
	end
end
