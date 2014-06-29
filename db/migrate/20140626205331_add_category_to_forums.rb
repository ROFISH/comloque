class AddCategoryToForums < ActiveRecord::Migration
  def change
    add_column :forums, :category_id, :integer
    add_column :forums, :category_permalink, :string
  end
end
