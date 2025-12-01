class AddCapacityLimitsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :capacity_limits, :jsonb
  end
end
