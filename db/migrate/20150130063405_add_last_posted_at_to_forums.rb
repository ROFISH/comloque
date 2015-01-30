class AddLastPostedAtToForums < ActiveRecord::Migration
  def change
    add_column :forums, :last_posted_at, :datetime
  end
end
