class Forum < ActiveRecord::Base
  belongs_to :category
  has_many :topics, ->{order({:id=>:desc})}, inverse_of: :forum

  LIQUEFIABLE_ATTRIBUTES = %i(name).freeze
  LIQUEFIABLE_METHODS = {url: :url, topics: :topics}.freeze
  LIQUEFIABLE_USER_METHODS = {can_create_topic?: :can_create_topic?}.freeze
  include Liquefiable

  include Permalinkable

  before_save :update_category_permalink, unless:->(x){x.category_id.blank?}

  class << self
    def public_scope(user)
      if user.try(:is_admin?)
        Forum.all
      else
        Forum.where(privacy:'public')
      end
    end
  end

  def url
    "/forum/#{category_permalink}/#{permalink}"
  end

  def can_create_topic?(user)
    return false if user.nil?     # unregistered anonymous folk not allowed to create topics
    return true if user.is_admin? # admins are always allowed to create topics
    return allow_create_topic     # otherwise, use the forum's setting
  end

  def update_category_permalink
    self.category_permalink = Category.find(self.category_id).permalink
  end

  def self.find_by_permalink_and_category_permalink(permalinktext,catlink)
    # attempt to look up thing first directly by the canonical permalink first. it's faster
    thing = find_by(permalink:permalinktext,category_permalink:catlink)
    return thing if thing

    raise "Unfinished Lookup"
  end
end
