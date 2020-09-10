source 'https://rubygems.org/'
ruby File.read('.ruby-version', mode: 'rb').chomp
#ruby-gemset=pwqgen

gem 'rack'
gem 'sinatra', "~> 2.1"
gem 'sinatra-contrib'
gem 'haml'
gem 'rdiscount'
gem 'rack-ssl-enforcer'
gem 'rack-timeout'
gem 'sprockets'
gem 'uglifier'

gem 'pwqgen.rb', "~> 0.1"
gem 'sys-uname'

group :production do
	gem 'newrelic_rpm'
	gem 'iodine', '~> 0.7'
end

group :test do
	gem 'cucumber'
	gem 'capybara'
	gem 'selenium-webdriver'
	gem 'rspec-expectations'
	gem 'rake'
end
