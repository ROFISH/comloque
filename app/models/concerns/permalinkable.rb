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

  included do |base|
    has_many :permalinks, as: :thang

    cattr_reader :permalinkable_autoset if base.class_variable_defined?(:@@permalinkable_autoset)
    cattr_reader :permalinkable_scoping

    if attribute_names.include?("permalink")
      validate :new_permalink_doesnt_exist, if:->(x){x.permalink_changed?}
      before_create :set_permalink_from_autoset, if:->(x){x.permalink.blank?} if base.class_variable_defined?(:@@permalinkable_autoset)
      before_update :set_permalink_from_autoset, if:->(x){x.__send__((x.class.permalinkable_autoset.to_s + "_changed?").to_sym)} if base.class_variable_defined?(:@@permalinkable_autoset)
      after_save :save_permalink, if:->(x){x.permalink_changed?}
    end
  end

  module ClassMethods
    def find_by_permalink(permalinktext)
      # attempt to look up thing first directly by the canonical permalink first. it's faster
      thing = find_by(permalink:permalinktext)
      return thing if thing

      # otherwise, we're not using the canonical link, lookup in the permalink table
      permalinkmodel = Permalink.find_by_name_and_thang_type(permalinktext,self.base_class.name)
      # will return nil if permalink is blank?
      permalinkmodel.try(:thang)
    end

    def find_by_permalink_and_scope_id(permalinktext,scope_id)
      # attempt to look up thing first directly by the canonical permalink first. it's faster
      thing = find_by({:permalink=>permalinktext,permalinkable_scoping=>scope_id})
      return thing if thing

      # otherwise, we're not using the canonical link, lookup in the permalink table
      permalinkmodel = Permalink.find_by_name_and_thang_type_and_scope_id(permalinktext,self.base_class.name,scope_id)
      # will return nil if permalink is blank?
      permalinkmodel.try(:thang)
    end
  end

  def new_permalink_doesnt_exist
    # AR uses `.class.base_class.name` to determine what goes in the type
    foundpermalink = Permalink.where(thang_type:self.class.base_class.name,name:self.permalink,scope_id:_permalinkable_scope_id).to_a
    # reject all permalinks if the one found is of the same type/id
    foundpermalink.reject!{|x| x.thang_id == self.id}
    # if the same permalink exists (and it's not the same object)
    unless foundpermalink.blank?
      errors.add(:permalink, "already exists")
    end
  end

  def _permalinkable_scope_id
    return nil unless self.class.permalinkable_scoping
    __send__(self.class.permalinkable_scoping)
  end

  def save_permalink
    Permalink.create(name:self.permalink,thang:self,scope_id:_permalinkable_scope_id)
  end

  def set_permalink_from_autoset
    self.permalink = __send__(self.class.permalinkable_autoset).parameterize
    permalink_will_change!
    1000.times do |i|
      break unless Permalink.exists?(name:self.permalink,thang_type:self.class.base_class.name)
      self.permalink = __send__(self.class.permalinkable_autoset).parameterize+"-#{i+1}"
    end
  end
end
