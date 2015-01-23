class User < ActiveRecord::Base
  LIQUEFIABLE_ATTRIBUTES = %i(name).freeze
  LIQUEFIABLE_METHODS = {}.freeze
  include Liquefiable
end
