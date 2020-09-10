Feature: Main Page

Scenario: Loading the main page
	Given I am on the main page
	Then the page should be loaded with a Generated Password

Scenario: Reloading the main page
	Given I am on the main page
	Then the page should be loaded with a Generated Password
	When I click Reload for another
	Then the page should be loaded with a Generated Password

Scenario: Loading the /m page
	Given I am on the /m page
	Then the page should be loaded with many Generated Passwords
	When I click Reload for more
	Then the page should be loaded with many Generated Passwords

Scenario: Loading the /txt page
	Given I am on the /txt page
	Then the page should be loaded with text
