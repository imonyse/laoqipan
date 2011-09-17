Factory.define :user do |user|
  user.sequence(:name) { |n| "user#{n}" }
  user.sequence(:email) { |n| "user#{n}@example.com"}
  user.password "foobar"
  user.password_confirmation "foobar"
  user.role "2"
end

Factory.define :game do |game|
  game.association(:black_player, :factory => :user) 
  game.association(:white_player, :factory => :user)
  game.current_player { |g| g.black_player}
  game.status "0"
  game.mode "2"
  game.sgf "(;FF[4]GM[1]SZ[19]RU[Chinese]KM[0]PB[black]PW[white]AB[pd][dp]AW[dd][pp])"
end

Factory.define :notice do |notice|
  notice.lang "zh"
  notice.body "system messages"
end

Factory.define :broadcast do |broadcast|
  broadcast.title  'first blog'
  broadcast.body   'Hello, blog'
  broadcast.brief  '1st'
  broadcast.association(:author, :factory => :user)
end