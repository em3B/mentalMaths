class MakeUserIdNullableOnAssignedTopics < ActiveRecord::Migration[8.0]
  def change
    change_column_null :assigned_topics, :user_id, true
  end
end
