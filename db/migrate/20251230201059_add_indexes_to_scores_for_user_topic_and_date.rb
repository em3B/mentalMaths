class AddIndexesToScoresForUserTopicAndDate < ActiveRecord::Migration[8.0]
  def change
    add_index :scores, [ :user_id, :created_at ]
    add_index :scores, [ :topic_id, :created_at ]
    add_index :scores, [ :user_id, :topic_id, :created_at ]
  end
end
