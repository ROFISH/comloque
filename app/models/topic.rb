class Topic < ActiveRecord::Base
  belongs_to :forum, inverse_of: :topics
  belongs_to :user
  has_many :messages

  LIQUEFIABLE_ATTRIBUTES = %i(name created_at).freeze
  LIQUEFIABLE_METHODS = {url: :url, user: :user, messages: :messages}.freeze
  LIQUEFIABLE_USER_METHODS = {can_reply?: :can_reply?}.freeze
  include Liquefiable

  # this before needs to be before the Permalinkable include
  @@permalinkable_autoset = :name
  @@permalinkable_scoping = :forum_id
  include Permalinkable

  def url
    "/forum/#{forum.category_permalink}/#{forum.permalink}/#{permalink}"
  end

  def can_reply?(user)
    return false if user.nil?         # unregistered anonymous folk not allowed to reply
    return true if user.is_admin?     # admins are always allowed to reply
    return forum.allow_create_message # otherwise, use the forum's setting
  end
end
