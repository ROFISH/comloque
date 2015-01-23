class Forum < ActiveRecord::Base
  belongs_to :category
  has_many :topics, ->{order({:id=>:desc})}, inverse_of: :forum
  has_many :moderatorships
  has_many :moderators, through: :moderatorships, source: :user

  LIQUEFIABLE_ATTRIBUTES = %i(name).freeze
  LIQUEFIABLE_METHODS = {url: :url, topics: :topics, moderators: :moderators}.freeze
  LIQUEFIABLE_USER_METHODS = {can_create_topic?: :can_create_topic?}.freeze
  include Liquefiable

  include Permalinkable

  before_save :update_category_permalink, unless:->(x){x.category_id.blank?}

  class << self
    def public_scope(user)
      if user.try(:is_admin?)
        Forum.all
      elsif user.moderatorships.length > 0
        arel = Forum.arel_table[:privacy].eq('public').or(Forum.arel_table[:id].in(user.moderatorships.map(&:forum_id)))
        Forum.where(arel)
      else
        Forum.where(privacy:'public')
      end
    end
  end

  def url
    "/forum/#{category_permalink}/#{permalink}"
  end

  def can_create_topic?(user)
    return false if user.nil?               # unregistered anonymous folk not allowed to create topics
    return true if user.is_mod_of? self.id  # mods of this forum are always allowed to create topics
    return true if user.is_admin?           # admins are always allowed to create topics
    return allow_create_topic               # otherwise, use the forum's setting
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

  # this is used for the select2 box to select moderators
  def moderator_tokens
    moderators.map{|x| {id:x.id,text:x.name}}.to_json#.inspect
  end

  def moderator_tokens=(tokens)
    self.moderator_ids = tokens.split(",").reject{|x| x.to_i<=0}
  end
end
