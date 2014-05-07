class Forum < ActiveRecord::Base
  include Liquefiable
  LIQUEFIABLE_ATTRIBUTES = %w(name).freeze

  include Permalinkable
end
