class Signature < ActiveRecord::Base
  attr_accessible :email, :name, :first_name, :last_name, :reference_type, :referer
  belongs_to :petition
  belongs_to :member
  belongs_to :referer, :class_name => 'Member', :foreign_key => 'referer_id'
  has_one :sent_email
  validates_presence_of :name, :first_name, :last_name
  validates :email, :presence => true, :email => true

  module ReferenceType
    FACEBOOK_LIKE = 'facebook_like'
    FACEBOOK_SHARE = 'facebook_share'
    TWITTER = 'twitter'
    EMAIL = 'email'
    SHARED_LINK = 'shared_link'
  end

  REFERENCE_TYPES = [ ReferenceType::FACEBOOK_LIKE, ReferenceType::FACEBOOK_SHARE, ReferenceType::TWITTER, ReferenceType::EMAIL, ReferenceType::SHARED_LINK, nil ]

  validates :reference_type, :inclusion => {:in => REFERENCE_TYPES, :message => "%{value} is not a valid reference_type"}

  before_save :truncate_user_agent

  def first_name 
    self.name.split(" ").first unless self.name.nil?
  end

  def last_name 
    self.name.split(" ").last unless self.name.nil?
  end

  def first_name=(val)
    self.name = "#{val} #{last_name}".strip
  end

  def last_name=(val)
    self.name = "#{first_name} #{val}".strip
  end

  def truncate_user_agent
    self.user_agent = self.user_agent[0..254]
  end
end
