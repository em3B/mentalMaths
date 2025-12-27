class AddUserToResponses < ActiveRecord::Migration[8.0]
  def change
    add_reference :responses, :user, null: false, foreign_key: true
  end
end
