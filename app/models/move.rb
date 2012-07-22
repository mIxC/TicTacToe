class Move < ActiveRecord::Base
  attr_accessible :position, :user_id, :game_id

  belongs_to :users
  belongs_to :games

  validates :position, :presence => TRUE,
                       :uniqueness => { :scope => :game_id },
                       :inclusion => { :in => 1..9,
                                       :message => 'not a valid position' }
  validate :valid_entities
  validate :user_turn
  validates_associated :users
  validates_associated :games

  def valid_entities
    errors.add(:user_id, 'is not valid user') unless User.find_by_id(user_id)
    errors.add(:game_id, 'is not valid game') unless Game.find_by_id(game_id)
  end

  def user_turn
    unless Game.find_by_id(game_id) && Game.find(game_id).current_user == user_id
      errors.add(:user_id, 'is not able to make a play')
    end
  end

end
