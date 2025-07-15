class AddScopedUniqueIndexToUsers < ActiveRecord::Migration[8.0]
  def change
    # If you already have a global index on username, remove it first
    remove_index :users, :username if index_exists?(:users, :username)

    # Add a **partial** unique index: only enforce uniqueness when classroom_id is present
    add_index :users, :username,
      unique: true,
      where: "classroom_id IS NOT NULL",
      name: "index_users_on_username_for_students"
  end
end
