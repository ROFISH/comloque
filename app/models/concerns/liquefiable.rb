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

  included do |base|
    klass = Class.new(Liquid::Drop)
    klass.include(ERB::Util)
    klass.__send__(:define_method,:initialize) {|thing| @thing = thing}

    base::LIQUEFIABLE_SANITIZED_ATTRIBUTES.each do |attr_name|
      klass.__send__(:define_method,attr_name) do
        h(@thing.attributes[attr_name.to_s])
      end
    end if defined? base::LIQUEFIABLE_SANITIZED_ATTRIBUTES

    base::LIQUEFIABLE_ATTRIBUTES.each do |attr_name|
      klass.__send__(:define_method,attr_name) do
        @thing.attributes[attr_name.to_s]
      end
    end if defined? base::LIQUEFIABLE_ATTRIBUTES

    base::LIQUEFIABLE_METHODS.each do |public_method, private_method|
      klass.__send__(:define_method,public_method) do
        @thing.__send__(private_method)
      end
    end if defined? base::LIQUEFIABLE_METHODS

    base::LIQUEFIABLE_USER_METHODS.each do |public_method, private_method|
      klass.__send__(:define_method,public_method) do
        @thing.__send__(private_method,@context.registers[:user])
      end
    end if defined? base::LIQUEFIABLE_USER_METHODS

    base.const_set(:Drop,klass)
  end

  def to_liquid
    @liquid ||= self.class::Drop.new(self)
  end

end
