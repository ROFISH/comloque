class Template < ActiveRecord::Base
  belongs_to :theme

  attr_accessor :is_layout, :altname, :is_snippet

  before_create :add_layout_to_name, if:->(x){!x.is_layout.blank?}
  before_create :add_snippet_to_name, if:->(x){!x.is_snippet.blank?}
  before_validation :add_altname_to_name, if:->(x){!x.altname.blank?}

  validates :name, presence: true, uniqueness: { scope: :theme_id }

  def add_layout_to_name
    self.name = "layout/#{self.name}"
  end

  def add_altname_to_name
    self.name = "#{self.name}.#{altname}"
  end

  def add_snippet_to_name
    self.name = "snippet/#{self.name}"
  end
end
