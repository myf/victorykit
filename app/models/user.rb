require "old_password_validator"

class User < ActiveRecord::Base
  attr_accessor :old_password
  validates_presence_of :password, on: :create
  validates_presence_of :password_confirmation, on: :create
  validates :old_password, :old_password => true, :presence => true,  :on => :update, :if => :password_digest_changed?
  attr_accessible :email, :password, :old_password, :password_confirmation
  attr_accessible :is_super_user, :is_admin, :as => :admin
  
  has_secure_password
  validates_uniqueness_of :email
  validates_presence_of :email
end
