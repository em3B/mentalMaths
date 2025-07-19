class AddAssignedByToAssignedTopics < ActiveRecord::Migration[8.0]
  def change
    add_reference :assigned_topics, :assigned_by, foreign_key: { to_table: :users }, index: true
  end
end
