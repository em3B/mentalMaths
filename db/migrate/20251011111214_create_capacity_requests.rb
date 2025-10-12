class CreateCapacityRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :capacity_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :request_type
      t.integer :quantity
      t.string :reason
      t.text :additional_info

      t.timestamps
    end
  end
end
