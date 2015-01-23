class AddPrivacyToForum < ActiveRecord::Migration
  def change
    add_column :forums, :privacy, :string, null: false, default: 'public'
  end
end
