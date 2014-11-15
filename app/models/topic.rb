class Topic < ActiveRecord::Base
  belongs_to :forum, inverse_of: :topics
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
    "/forum/#{forum.category_permalink}/#{forum.permalink}/#{permalink}"
  end
end
