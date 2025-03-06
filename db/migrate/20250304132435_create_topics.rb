class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics do |t|
      t.string :title, null: false, unique: true
      t.text :intro

      t.timestamps
    end
    add_index :topics, :title, unique: true
  end
end
