class AddPublicToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :public, :boolean
  end
end
