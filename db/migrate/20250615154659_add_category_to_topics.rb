class AddCategoryToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :category, :string
  end
end
