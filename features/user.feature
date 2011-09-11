Feature: user
	In order to play with others
	As a visitor
	I want to be able to register
	

	Scenario: existing user signin
		Given a user name "tidy", email "tidy@example.com" with password "foobar"
		And I am on the home page
		When I fill in "session_email" with "tidy@example.com"
		And I fill in "session_password" with "foobar"
		And I press "session_submit"
		Then I should be on tidy's personal page
		And I should see "tidy"
		And I should see "登出"
		
	@javascript
	Scenario: user challenge user
		Given a user name "tidy", email "tidy@example.com" with password "foobar"
		And a user name "foo", email "foo@example.com" with password "foobar"
		And I am on the home page
		And I login as "foo@example.com" with password "foobar"
		When I click_div "#duel_list div.collapse"
		And I wait until text "邀请" is visible
		And I follow "邀请"
		And I select "现代棋" from "game_mode"
		And I press "game_submit"
		Then I should see "等待对手落子确认"



