class AddCorrectAndTotalToScores < ActiveRecord::Migration[8.0]
  def change
    add_column :scores, :correct, :integer
    add_column :scores, :total, :integer
  end
end
