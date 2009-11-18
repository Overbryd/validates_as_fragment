class Model < ActiveRecord::Base  
  validates_as_fragment :indicator => :incomplete, :except => [:email, :password_digest]
  
  validates_presence_of :salt, :password_digest, :first_name, :last_name, :email, :date_of_birth
  validates_format_of :email, :with => /^.+@.+\.\w+$/, :allow_blank => true
  validates_uniqueness_of :email
  
  attr_accessible :first_name, :last_name, :email, :password, :date_of_birth

  def password=(password)
    self.salt = "salt"
    self.password_digest = password.reverse
  end
end

