class Classroom < ApplicationRecord
  belongs_to :teacher, class_name: "User"
  has_many :students, class_name: "User", dependent: :nullify
end
