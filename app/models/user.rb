class User < ActiveRecord::Base
  include Liquefiable
  LIQUEFIABLE_ATTRIBUTES = %w(name).freeze
  LIQUEFIABLE_METHODS = [].freeze
end
