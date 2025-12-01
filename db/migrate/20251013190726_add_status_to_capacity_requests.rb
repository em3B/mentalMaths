class AddStatusToCapacityRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :capacity_requests, :status, :string
  end
end
