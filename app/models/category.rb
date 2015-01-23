class Category < ActiveRecord::Base
  has_many :forums
  has_many :public_forums, ->{ where(privacy:'public') }, class_name: :Forum

  include Permalinkable

  after_save :set_forum_cat_permalink, if:->(x){x.permalink_changed?}

  def set_forum_cat_permalink
    Forum.where(category_id:self.id).update_all(category_permalink:self.permalink)
  end

  def url
    "/forum/#{permalink}"
  end
end
