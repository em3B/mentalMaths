class ChangeRequestTypeToStringInCapacityRequests < ActiveRecord::Migration[8.0]
  def change
    change_column :capacity_requests, :request_type, :string
  end
end
