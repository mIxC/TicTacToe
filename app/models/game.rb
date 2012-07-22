class Game < ActiveRecord::Base
  attr_accessible :name, :user1_id, :user2_id, :current_user

  has_many :moves, :dependent => :destroy

  validates :name, :presence => TRUE, 
                   :length => { :within => 3..50 }
  validates :user1_id, :presence => TRUE
  validates :current_user, :presence => TRUE
  validate  :valid_users

  def valid_users
    errors.add(:user1_id, 'is not valid user') unless User.find_by_id(user1_id)
    errors.add(:current_user, 'is not valid user') unless User.find_by_id(current_user)
    unless user2_id.nil?
      errors.add(:user2_id, 'is not valid user') unless User.find_by_id(user2_id)
    end
  end

end
