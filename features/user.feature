Feature: user
	In order to play with others
	As a visitor
	I want to be able to register
	

	Scenario: existing user signin
		Given a user name "tidy", email "tidy@example.com" with password "foobar"
		And I am on the home page
		When I fill in "session_email" with "tidy@example.com"
		And I fill in "session_password" with "foobar"
		And I press "继续"
		Then I should be on tidy's personal page
		And I should see "tidy"
		And I should see "登出"
		
	@javascript
	Scenario: user challenge user
		Given a user name "tidy", email "tidy@example.com" with password "foobar"
		And a user name "foo", email "foo@example.com" with password "foobar"
		And I am on the home page
		And I login as "foo@example.com" with password "foobar"
		When I on the rails duel page
		And I follow "邀请"
		And I select "现代棋" from "game_mode"
		And I press "发出对局邀请"
		Then I should see "等待对手落子确认"



