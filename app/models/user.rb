class User < ActiveRecord::Base
  attr_accessible :name, :password, :password_confirmation
  has_secure_password

  before_save :create_remember_token

  validates :password, :presence => TRUE, 
                       :confirmation => TRUE,
                       :length => { :within => 6..50 }
  validates :name, :presence => TRUE, 
                   :length => { :within => 3..50 } ,
                   :uniqueness => { :case_sensitive => FALSE }                      

  has_many :moves, :dependent => :destroy
  
  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
