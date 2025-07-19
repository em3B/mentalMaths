class AddClassroomToAssignedTopics < ActiveRecord::Migration[8.0]
  def change
    add_reference :assigned_topics, :classroom, foreign_key: true, index: true
  end
end
