# -*- coding: utf-8 -*-
Given /^a game created by white_player "([^"]*)" and black_player "([^"]*)" and current_player "([^"]*)" with sgf:$/ do |arg1, arg2, arg3, string|
  Game.create({ :black_player => User.find_by_name(arg2), 
                :white_player => User.find_by_name(arg1), 
                :current_player => User.find_by_name(arg3), 
                :mode => 1,
                :access => 0,
                :sgf => string })
end

When /^I wait until game finished loading$/ do
  wait_until do
    page.has_content? "已连接"
  end
end

When /^I wait until ended game finished loading$/ do
  wait_until do
    div = page.find(:css, '#board_info')
    div.visible?
  end
end

When /^I wait for "([^"]*)" seconds$/ do |arg1|
  sleep arg1.to_i
end

When /^I click "([^"]*)"$/ do |arg1|
  click_link arg1
end

When /^I click_div "([^"]*)"$/ do |arg1|
  div = page.find(:css, arg1)
  div.click
end

Then /^"([^"]*)" should be invisible$/ do |arg1|
  div = page.find(:css, arg1)
  unless !div.visible?
    sleep 2.second
  end
  assert !div.visible?
end

Then /^"([^"]*)" should be visible$/ do |arg1|
  div = page.find(:css, arg1)
  unless div.visible?
    sleep 1.second
  end
  assert div.visible?
end

When /^I click_game_item$/ do
  find(:css, ".game_thumbnail").click
end

When /^I click_li "([^"]*)"$/ do |arg1|
  item = page.find(:css, arg1)
  item.click
end

When /^I on the rails (.+) page$/ do |arg1|
  eval("visit #{arg1}_path")
end
