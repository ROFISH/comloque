class Message < ActiveRecord::Base
  belongs_to :user

  LIQUEFIABLE_ATTRIBUTES = %i(body).freeze
  LIQUEFIABLE_METHODS = %i(user).freeze
  include Liquefiable
end
