class AddRequiresAuthToTopics < ActiveRecord::Migration[8.0]
  def change
    add_column :topics, :requires_auth, :boolean
  end
end
