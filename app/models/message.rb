class Message < ActiveRecord::Base
  include ERB::Util

  belongs_to :user
  belongs_to :topic

  LIQUEFIABLE_ATTRIBUTES = %i(id).freeze
  LIQUEFIABLE_METHODS = {user: :user, created_at: :created_at, updated_at: :updated_at, url: :url, body: :sanitized_body, body_original: :body_original}.freeze
  include Liquefiable

  include Sanitizable

  def url
    "#{topic.url}/#{id}"
  end

  def body_original
    html_escape(body)
  end

  def sanitized_body
    basic_sanitize(body)
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
