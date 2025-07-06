class AddClassroomIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :classroom_id, :bigint
    add_index  :users, :classroom_id
    add_foreign_key :users, :classrooms
  end
end
