class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  LIQUEFIABLE_ATTRIBUTES = %i(id).freeze
  LIQUEFIABLE_METHODS = {user: :user, created_at: :created_at, updated_at: :updated_at, message: :message, url: :url}.freeze
  include Liquefiable

  def can_edit?(user)
    return false if user.nil?                                   # unregistered anonymous folk not allowed to take this report
    return true if user.is_admin?                               # admins are always allowed to take this report
    return true if user.is_mod_of? self.message.topic.forum_id  # mods of this forum are allowed to take this report
    return false
  end

  def url
    "#{message.url}/take_report"
  end
end
