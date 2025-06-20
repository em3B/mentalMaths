class Classroom < ApplicationRecord
  belongs_to :teacher, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :students, through: :memberships, source: :user
end
