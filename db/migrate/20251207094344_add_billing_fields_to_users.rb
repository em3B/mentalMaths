class AddBillingFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :stripe_customer_id, :string
    add_column :users, :stripe_subscription_id, :string
    add_column :users, :plan_name, :string
    add_column :users, :billing_status, :string
    add_column :users, :subscription_ends_at, :datetime
  end
end
