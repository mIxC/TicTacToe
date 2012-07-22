Factory.define :user do |user|
    user.name                   'Jason Bourne'
    user.password               'freedom'
    user.password_confirmation  'freedom'
end

Factory.define :game do |game|
    game.name                   'gameName'
    game.user1_id               '1'
    game.user2_id               '2'
    game.current_user           '1'
end

Factory.define :move do |move|
  move.position                 '1'
  move.user_id                  '1'
  move.game_id                  '1'
end

Factory.sequence :name do |n|
    "Entity #{n}"
end