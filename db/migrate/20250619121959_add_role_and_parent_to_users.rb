class AddRoleAndParentToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :integer
    add_column :users, :parent_id, :integer
  end
end
