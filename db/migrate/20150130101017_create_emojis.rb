class CreateEmojis < ActiveRecord::Migration
  def change
    create_table :emojis do |t|
      t.string :name
      t.string :image

      t.timestamps null: false
    end
  end
end
