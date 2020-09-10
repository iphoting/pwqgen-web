require 'capybara/cucumber'

Given /I am on the main page/ do
  visit('/')
end

Given /I am on the \/m page/ do
  visit('/m')
end

Given /I am on the \/txt page/ do
  visit('/txt')
end

Then /the page should be loaded with a (.+)/ do |text|
	expect(page).to have_text(text)
	expect(page).to have_field('password', type: 'text')
end

Then /the page should be loaded with many (.+)/ do |text|
	expect(page).to have_text(text)
	expect(page).to have_selector('#content > pre')
end

Then /the page should be loaded with text/ do
	expect(page.response_headers['Content-Type']).to have_text('text/plain')
end

When /I click (.+)/ do |link|
	click_link link
end

Then /the page should say "(.+)"/ do |url|
	expect(page).to have_text(url)
end
