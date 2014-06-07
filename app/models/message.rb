class Message < ActiveRecord::Base
  belongs_to :user

  include Liquefiable
  LIQUEFIABLE_ATTRIBUTES = %w(body).freeze
  LIQUEFIABLE_METHODS = %i(user).freeze
end
