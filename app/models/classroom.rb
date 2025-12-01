class Classroom < ApplicationRecord
  belongs_to :teacher, class_name: "User"
  has_many :students, class_name: "User", dependent: :nullify
  has_many :assigned_topics
  has_many :topics, through: :assigned_topics
  validate :within_teacher_classroom_limit, on: :create
  validate :within_classroom_student_limit, on: :update

  private

  def within_teacher_classroom_limit
    return unless teacher.present?

    limit = teacher.capacity_limits&.dig("classroom") || 10
    if teacher.classrooms.count >= limit
      errors.add(:base, "You have reached your classroom limit of #{limit}. You can submit a request for more.")
    end
  end

  def within_classroom_student_limit
    return unless teacher.present?

    limit = teacher.capacity_limits&.dig("student") || 40
    if students.size > limit
      errors.add(:base, "This classroom has reached your student limit of #{limit}. You can submit a request for more.")
    end
  end
end
