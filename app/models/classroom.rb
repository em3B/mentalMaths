class Classroom < ApplicationRecord
  belongs_to :teacher, class_name: "User"
  has_many :students, class_name: "User", dependent: :nullify
  has_many :assigned_topics
  has_many :topics, through: :assigned_topics

  SOFT_LIMIT_CLASSROOMS = 10
  SOFT_LIMIT_STUDENTS = 50

  validate :soft_limit_classrooms, on: :create
  validate :soft_limit_students, on: :update

  private

  def soft_limit_classrooms
    return unless teacher.classrooms.count >= SOFT_LIMIT_CLASSROOMS
    errors.add(:base, "You have reached the recommended limit of #{SOFT_LIMIT_CLASSROOMS} classrooms. You can submit a request for more.")
  end

  def soft_limit_students
    return unless students.size > SOFT_LIMIT_STUDENTS
    errors.add(:base, "This classroom has reached the recommended student limit of #{SOFT_LIMIT_STUDENTS}. You can submit a request for more.")
  end
end
