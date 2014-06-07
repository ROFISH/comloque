class Topic < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  has_many :messages

  include Liquefiable
  LIQUEFIABLE_ATTRIBUTES = %w(name).freeze
  LIQUEFIABLE_METHODS = %i(url user).freeze

  # this before needs to be before the Permalinkable include
  AUTOSET_PERMALINK = :name
  include Permalinkable

  def url
    "/forum/todo_category/#{forum.permalink}/#{permalink}"
  end
end
