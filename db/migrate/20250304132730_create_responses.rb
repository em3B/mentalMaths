class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.references :question, null: false, foreign_key: true
      t.integer :value

      t.timestamps
    end
  end
end
