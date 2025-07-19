class AddFieldsToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :contact_email, :string
    add_column :schools, :subscription_status, :string
    add_column :schools, :subscription_expires_at, :datetime
  end
end
