class AddPendingPaymentToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :pending_payment, :boolean, default: true
  end
end
