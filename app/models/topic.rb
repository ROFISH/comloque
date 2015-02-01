class Topic < ActiveRecord::Base
  belongs_to :forum, inverse_of: :topics
  belongs_to :user
  has_many :messages

  LIQUEFIABLE_ATTRIBUTES = %i(id created_at last_posted_at messages_count views).freeze
  LIQUEFIABLE_SANITIZED_ATTRIBUTES = %i(name).freeze
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
    return false if user.nil?                     # unregistered anonymous folk not allowed to reply
    return true if user.is_admin?                 # admins are always allowed to reply
    return true if user.is_mod_of? self.forum_id  # mods of this forum are always allowed to reply
    return forum.allow_create_message             # otherwise, use the forum's setting
  end

  def can_edit?(user)
    return false if user.nil?                           # unregistered anonymous folk not allowed to edit
    return true if user.id == self.user_id              # users are allowed to edit their own topics
    return true if user.is_admin?                       # admins are always allowed to edit
    return true if user.is_mod_of? self.topic.forum_id  # mods of this forum are allowed to edit
    return false                                        # otherwise, no
  end

  def reset_cached_metadata
    new_touch = Message.where(topic_id:id).order(:created_at=>:desc).first.try(:created_at)
    new_count = Message.where(topic_id:id).count
    update(last_posted_at:new_touch.try(:to_s,:db),messages_count:new_count)
  end
end
