class Message < ActiveRecord::Base
  include Liquefiable
  LIQUEFIABLE_ATTRIBUTES = %w(body).freeze
  LIQUEFIABLE_METHODS = %i().freeze
end
