class Classroom < ApplicationRecord
  belongs_to :teacher, class_name: "User"
  has_many :students, class_name: "User", dependent: :nullify
  has_many :assigned_topics
  has_many :topics, through: :assigned_topics
end
