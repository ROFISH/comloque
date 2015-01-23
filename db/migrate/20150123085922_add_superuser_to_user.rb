class AddSuperuserToUser < ActiveRecord::Migration
  def change
    add_column :users, :superuser, :string
  end
end
