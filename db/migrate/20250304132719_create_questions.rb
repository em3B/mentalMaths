class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :topic, null: false, foreign_key: true
      t.text :question_text
      t.integer :correct_answer

      t.timestamps
    end
  end
end
