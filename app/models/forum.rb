class Forum < ActiveRecord::Base
  has_many :topics

  LIQUEFIABLE_ATTRIBUTES = %i(name).freeze
  LIQUEFIABLE_METHODS = %i(url).freeze
  include Liquefiable

  include Permalinkable

  def url
    "/forum/todo_category/#{permalink}"
  end
end
