class Theme < ActiveRecord::Base
  has_many :templates
  has_many :assets
end
