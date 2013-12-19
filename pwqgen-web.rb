require 'rubygems'
require 'bundler'

require 'sinatra'
require 'haml'
require 'rack-timeout'
require 'sys/uname'
require 'pwqgen'

configure :production do
	require 'newrelic_rpm'
	require 'rack/ssl-enforcer'
	use Rack::SslEnforcer, :hsts => true
end

use Rack::Timeout
Rack::Timeout.timeout = 10
use Rack::ConditionalGet
use Rack::ETag
use Rack::ContentLength
use Rack::Deflater

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
