class CreateAssignedTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :assigned_topics do |t|
      t.references :user, null: false, foreign_key: true
      t.references :topic, null: false, foreign_key: true
      t.date :due_date

      t.timestamps
    end
  end
end
