class RemoveValueFromScores < ActiveRecord::Migration[8.0]
  def change
    remove_column :scores, :value, :integer
  end
end
