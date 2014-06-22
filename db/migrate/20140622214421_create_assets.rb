class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :key
      t.string :attachment
      t.string :content_type
      t.integer :size
      t.integer :width
      t.integer :height
      t.integer :theme_id
      t.string :digest

      t.timestamps
    end
  end
end
