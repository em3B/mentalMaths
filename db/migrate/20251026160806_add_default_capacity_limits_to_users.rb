class AddDefaultCapacityLimitsToUsers < ActiveRecord::Migration[8.0]
  def up
    User.reset_column_information
    User.find_each do |user|
      user.capacity_limits ||= { "classroom" => 10, "student" => 40, "child" => 10 }
      user.save!(validate: false)
    end
  end
end
