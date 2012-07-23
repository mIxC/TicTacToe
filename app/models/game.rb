class Game < ActiveRecord::Base
  attr_accessible :name, :user1_id, :user2_id, :current_user

  has_many :moves, :dependent => :destroy

  validates :name, :presence => TRUE, 
                   :length => { :within => 3..50 }
  validates :user1_id, :presence => TRUE
  validates :current_user, :presence => TRUE
  validate  :valid_users

  include GamesHelper

  def valid_users
    errors.add(:user1_id, 'is not valid user') unless User.find_by_id(user1_id)
    errors.add(:current_user, 'is not valid user') unless User.find_by_id(current_user)
    unless user2_id.nil?
      errors.add(:user2_id, 'is not valid user') unless User.find_by_id(user2_id)
    end
  end

  def no_moves_left?
    allMovesA = Array.new
    moves.each do |m|
      allMovesA << m.position
    end
    allMovesA = allMovesA.uniq.sort
    allMovesA == [1,2,3,4,5,6,7,8,9]
  end

  def set_next_player
    if user1_id == current_user
      update_attribute(:current_user, user2_id)
      user2_id
    elsif user2_id == current_user
      update_attribute(:current_user, user1_id)
      user1_id
    end
    if current_user == computer_player.id && outcome.nil?
      make_computer_move(game)
    end
  end

  def check_game_status
    movesB = Array.new
    movesA = Array.new

    moves.each do |m|
      movesA << m.position if m.user_id == user1_id
      movesB << m.position if m.user_id == user2_id
    end
    
    winning_moves1 = winning_moves_filter(movesA)
    winning_moves2 = winning_moves_filter(movesB)
    
    if winning_moves1
      update_attribute(:outcome,user1_id)
      winning_moves1
    elsif winning_moves2
      update_attribute(:outcome,user2_id)
      winning_moves2
    elsif no_moves_left?
      update_attribute(:outcome,0)
      'draw'
    else
      nil
    end
  end  

end
