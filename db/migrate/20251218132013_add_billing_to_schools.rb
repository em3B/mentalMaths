class AddBillingToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :stripe_customer_id, :string
    add_column :schools, :stripe_subscription_id, :string
    add_column :schools, :plan_name, :string
    add_column :schools, :billing_status, :string
    add_column :schools, :subscription_ends_at, :datetime
    add_column :schools, :seat_limit, :integer, default: 0, null: false
    add_column :schools, :seats_used, :integer, default: 0, null: false

    add_index :schools, :stripe_customer_id
    add_index :schools, :stripe_subscription_id
  end
end
