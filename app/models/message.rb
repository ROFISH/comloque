class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic

  LIQUEFIABLE_ATTRIBUTES = %i(id body).freeze
  LIQUEFIABLE_METHODS = %i(user created_at updated_at url).freeze
  include Liquefiable

  def url
    "#{topic.url}/#{id}"
  end
end
