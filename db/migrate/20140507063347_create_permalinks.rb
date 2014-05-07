class CreatePermalinks < ActiveRecord::Migration
  def change
    create_table :permalinks do |t|
      t.string :name
      t.integer :thang_id
      t.string :thang_type

      t.timestamps
    end
  end
end
