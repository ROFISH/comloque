class Topic < ActiveRecord::Base
  include Liquefiable
  LIQUEFIABLE_ATTRIBUTES = %w(name).freeze
  LIQUEFIABLE_METHODS = %i(url).freeze

  include Permalinkable

  before_create :set_permalink

  def url
    "/forum/todo_category/#{forum.permalink}/#{permalink}"
  end

  def set_permalink
    self.permalink = name.parameterize
    # loop protection
    1000.times do |i|
      break unless Topic.exists?(permalink:self.permalink)
      self.permalink = name.parameterize+"-#{i+1}"
    end
  end
end
