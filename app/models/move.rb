class Move < ActiveRecord::Base
  attr_accessible :position, :user_id, :game_id

  belongs_to :users
  belongs_to :games
end
