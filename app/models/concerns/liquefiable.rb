module Liquefiable
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

  def to_liquid
    allowable = self.class::LIQUEFIABLE_ATTRIBUTES
    allowed_attributes = attributes.select{|k,v| allowable.include?(k)}
    allowed_methods = Hash[self.class::LIQUEFIABLE_METHODS.map{|sym| [sym.to_s,__send__(sym)]}]

    allowed_attributes.merge(allowed_methods)
  end

end
