class CreateSwearWords < ActiveRecord::Migration
  def change
    create_table :swear_words do |t|
      t.string :word
      t.boolean :case_sensitive, :default => false, :null => false
      t.string :mask
      t.boolean :require_beginning_space, :default => true, :null => false
      t.boolean :require_ending_space, :default => true, :null => false

      t.timestamps null: false
    end
  end
end
