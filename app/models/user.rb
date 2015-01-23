class User < ActiveRecord::Base
  LIQUEFIABLE_ATTRIBUTES = %i(name).freeze
  include Liquefiable

  def is_admin?
    superuser == 'administrator'
  end
end
