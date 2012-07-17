class Game < ActiveRecord::Base
  attr_accessible :name, :user1_id, :user2_id, :current_user

  has_many :moves, :dependent => :destroy
  has_many :users
end
