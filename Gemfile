source :rubygems
ruby "1.9.3" if Bundler::VERSION >= "1.2.0"

gem 'thin'
gem 'rack'
gem 'sinatra', :github => "sinatra"
gem 'haml'
gem 'rdiscount'
gem 'rack-ssl-enforcer'
gem 'pwqgen.rb', "~> 0.0.4"
gem 'sys-uname'

group :development do
	gem 'foreman'
end

group :production do
	gem 'newrelic_rpm'
end

