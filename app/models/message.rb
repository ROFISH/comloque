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
end
