class Topic < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  has_many :messages

  LIQUEFIABLE_ATTRIBUTES = %i(name created_at).freeze
  LIQUEFIABLE_METHODS = %i(url user messages).freeze
  include Liquefiable

  # this before needs to be before the Permalinkable include
  @@permalinkable_autoset = :name
  @@permalinkable_scoping = :forum_id
  include Permalinkable

  def url
    "/forum/todo_category/#{forum.permalink}/#{permalink}"
  end
end
