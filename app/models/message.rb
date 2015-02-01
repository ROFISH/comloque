class Message < ActiveRecord::Base
  include ERB::Util

  belongs_to :user
  belongs_to :topic

  LIQUEFIABLE_ATTRIBUTES = %i(id).freeze
  LIQUEFIABLE_METHODS = {user: :user, created_at: :created_at, updated_at: :updated_at, url: :url, body: :sanitized_body, body_original: :body_original}.freeze
  include Liquefiable

  include Sanitizable

  after_create :increment_counter_and_touch_topic, unless: ->(x){x.topic_id.blank?}
  after_destroy :decrement_counter_and_touch_topic

  def increment_counter_and_touch_topic
    Topic.where(id:topic_id).update_all(["messages_count = COALESCE(messages_count, 0) + 1, last_posted_at = ?",self.created_at.to_s(:db)])
    Forum.where(id:topic.forum_id).update_all(["last_posted_at = ?",self.created_at.to_s(:db)]) if topic.forum_id
  end

  def decrement_counter_and_touch_topic
    new_touch = Message.where(topic_id:topic_id).order(:created_at=>:desc).first.try(:created_at)
    Topic.where(id:topic_id).update_all(["messages_count = COALESCE(messages_count, 0) - 1, last_posted_at = ?",new_touch.try(:to_s,:db)])
  end

  def url
    "#{topic.url}/#{id}"
  end

  def body_original
    html_escape(body)
  end

  def sanitized_body
    basic_sanitize(body,[Emoji::SanitizeTransformer.new,SwearWord::SanitizeTransformer.new])
  end

  def can_edit?(user)
    return false if user.nil?                           # unregistered anonymous folk not allowed to edit
    return true if user.id == self.user_id              # users are allowed to edit their own posts
    return true if user.is_admin?                       # admins are always allowed to edit
    return true if user.is_mod_of? self.topic.forum_id  # mods of this forum are allowed to edit
    return false                                        # otherwise, no
  end

  def can_delete?(user)
    return false if user.nil?                           # unregistered anonymous folk not allowed to delete
    return true if user.is_admin?                       # admins are always allowed to delete
    return true if user.is_mod_of? self.topic.forum_id  # mods of this forum are allowed to delete
    return false                                        # otherwise, no
  end
end
