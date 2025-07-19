class AddCreatedByFamilyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :created_by_family, :boolean
  end
end
