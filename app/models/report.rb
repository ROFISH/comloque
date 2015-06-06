class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  LIQUEFIABLE_ATTRIBUTES = %i(id).freeze
  LIQUEFIABLE_METHODS = {user: :user, created_at: :created_at, updated_at: :updated_at, message: :message, url: :liquid_url, id: :id}.freeze
  include Liquefiable

  validate :cannot_delete_only_post

  def cannot_delete_only_post
    if @_deleted_message && message.topic.messages.count <= 1
      errors.add :delete_post,"Cannot delete post since it is the only post."
    end
  end

  def can_edit?(user)
    if self.message.blank?
      self.destroy
      return false
    end

    return false if user.nil?                                   # unregistered anonymous folk not allowed to take this report
    return true if user.is_admin?                               # admins are always allowed to take this report
    return true if user.is_mod_of? self.message.topic.forum_id  # mods of this forum are allowed to take this report
    return false
  end

  def url
    "#{message.try(:url)}/report"
  end

  def liquid_url
    "#{message.try(:url)}/report/edit"
  end

  def add_resolution_action(newaction)
    resolution_action_array << newaction
    self.resolution_actions = resolution_action_array.join(",")
  end

  def resolution_action_array
    @_resolution_actions ||= (resolution_actions.try(:split,",") || [])
  end

  def delete_post
    resolution_action_array.include?("delete_message")
  end

  def delete_post=(newvalue)
    if newvalue === true || newvalue === "1"
      add_resolution_action "delete_message"
      message.destroy
      @_deleted_message = true
    end
  end

  def lock_topic
    resolution_action_array.include?("lock_topic")
  end

  def lock_topic=(newvalue)
    if newvalue === true || newvalue === "1"
      add_resolution_action "lock_topic"
      message.topic.update(locked_at:Time.now) if message.topic.locked_at.blank?
    end
  end
end
