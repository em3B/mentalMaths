class AddSchoolAdminToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :school_admin, :boolean, default: false, null: false
  end
end
