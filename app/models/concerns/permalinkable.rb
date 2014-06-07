module Permalinkable
  extend ActiveSupport::Concern

  # included do
  #   has_many :taggings, as: :taggable
  #   has_many :tags, through: :taggings

  #   class_attribute :tag_limit
  # end

  # def tags_string
  #   tags.map(&:name).join(', ')
  # end

  # def tags_string=(tag_string)
  #   tag_names = tag_string.to_s.split(', ')

  #   tag_names.each do |tag_name|
  #     tags.build(name: tag_name)
  #   end
  # end

  # # methods defined here are going to extend the class, not the instance of it
  # module ClassMethods

  #   def tag_limit(value)
  #     self.tag_limit_value = value
  #   end

  # end

  included do
    has_many :permalinks, as: :thang

    if attribute_names.include?("permalink")
      validate :new_permalink_doesnt_exist, if:->(x){x.permalink_changed?}
      before_save :save_permalink, if:->(x){x.permalink_changed?}
    end
  end

  def new_permalink_doesnt_exist
    # AR uses `.class.base_class.name` to determine what goes in the type
    foundpermalink = Permalink.where(thang_type:self.class.base_class.name,name:self.permalink).to_a
    # reject all permalinks if the one found is of the same type/id
    foundpermalink.reject!{|x| x.thang_id == self.id}
    # if the same permalink exists (and it's not the same object)
    unless foundpermalink.blank?
      errors.add(:permalink, "already exists")
    end
  end

  def save_permalink
    Permalink.create(name:self.permalink,thang:self)
  end

  def find_by_permalink(permalink)
    permalink = Permalink.find_by_name_and_thang_type(params[:forum],self.class.base_class.name)
    # will return nil if permalink is blank?
    permalink.try(:thang)
  end
end
