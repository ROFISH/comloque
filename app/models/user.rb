class User < ActiveRecord::Base
  LIQUEFIABLE_ATTRIBUTES = %i(name).freeze
  LIQUEFIABLE_METHODS = {}.freeze
  include Liquefiable

  def is_admin?
    superuser == 'administrator'
  end
end
