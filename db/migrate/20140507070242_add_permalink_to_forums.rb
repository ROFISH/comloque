class AddPermalinkToForums < ActiveRecord::Migration
  def change
    add_column :forums, :permalink, :string
  end
end
