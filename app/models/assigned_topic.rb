class AssignedTopic < ApplicationRecord
  belongs_to :topic
  belongs_to :assigned_by, class_name: "User"
  belongs_to :user, optional: true
  belongs_to :classroom, optional: true

  # Ensure exactly one of :user or :classroom is present
  validates :user_id, presence: true, unless: -> { classroom_id.present? }
  validates :classroom_id, presence: true, unless: -> { user_id.present? }

  # Optional: Validate that assigned_by is a teacher or family
  validate :assigned_by_authorized

  private

  def assigned_by_authorized
    unless assigned_by&.teacher? || assigned_by&.family?
      errors.add(:assigned_by, "must be a teacher or family user")
    end
  end
end
