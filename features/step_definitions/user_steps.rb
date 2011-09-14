# -*- coding: utf-8 -*-
Given /^a user name "([^"]*)", email "([^"]*)" with password "([^"]*)"$/ do |arg1, arg2, arg3|
  User.create({:name => arg1, :email => arg2, :password => arg3, :password_confirmation => arg3})
end

Given /^I login as "([^"]*)" with password "([^"]*)"$/ do |arg1, arg2|
  When 'I fill in "session_email" with "'+arg1+'"'
  And 'I fill in "session_password" with "'+arg2+'"'
  And 'I press "继续"'
end

When /^I logout$/ do
  click_link "登出"
end

Then /^user "([^"]*)" should have record wins "([^"]*)" and loses "([^"]*)"$/ do |arg1, arg2, arg3|
  user = User.find_by_name(arg1)
  assert(user.wins == arg2.to_i)
  assert(user.loses == arg3.to_i)
end

When /^I wait until text "([^"]*)" is visible$/ do |arg1|
  wait_until do
    page.has_content? arg1
  end
end

When /^I wait until "([^"]*)" is visible$/ do |arg1|
  wait_until do
    item = page.find(:css, arg1)
    item.visible?
  end
end
