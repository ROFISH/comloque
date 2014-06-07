class Topic < ActiveRecord::Base
  include Liquefiable
  LIQUEFIABLE_ATTRIBUTES = %w(name).freeze
  LIQUEFIABLE_METHODS = %i(url).freeze

  include Permalinkable

  def url
    "/forum/todo_category/#{forum.permalink}/#{permalink}"
  end
end
