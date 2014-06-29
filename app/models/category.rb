class Category < ActiveRecord::Base
  has_many :forums

  LIQUEFIABLE_ATTRIBUTES = %i(name).freeze
  LIQUEFIABLE_METHODS = %i(url forums).freeze
  include Liquefiable

  include Permalinkable

  after_save :set_forum_cat_permalink, if:->(x){x.permalink_changed?}

  def set_forum_cat_permalink
    Forum.where(category_id:self.id).update_all(category_permalink:self.permalink)
  end

  def url
    "/forum/#{permalink}"
  end
end
