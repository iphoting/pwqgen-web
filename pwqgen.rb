require 'rubygems'
require 'bundler'
Bundler.setup(:default, ENV['RACK_ENV'])

require 'sinatra'
require 'haml'
require 'rack/ssl-enforcer'

configure :production do
	require 'newrelic_rpm'
	use Rack::SslEnforcer
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
	`./pwqgen.static`
end
