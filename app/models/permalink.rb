class Permalink < ActiveRecord::Base
  belongs_to :thang, polymorphic: true
end
