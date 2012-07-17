class User < ActiveRecord::Base
  attr_accessible :name, :password, :password_confirmation
  has_secure_password

  before_save :create_remember_token

  validates :password, presence: true, length: { minimum: 6 }

  has_many :moves, :dependent => :destroy
  
  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
