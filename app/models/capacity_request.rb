class CapacityRequest < ApplicationRecord
  belongs_to :user

  after_initialize { self.status ||= "pending" }

  REQUEST_TYPES = {
    classroom: 0,
    student: 1,
    child: 2
  }.freeze

  validates :request_type, presence: true, inclusion: { in: REQUEST_TYPES.values }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :reason, presence: true

  # -------------------------
  # Convenience helper methods
  # -------------------------

  # Returns :classroom, :student, :child, or nil
  def request_type_symbol
    REQUEST_TYPES.key(request_type)
  end

  # Returns 0, 1, 2, or nil
  def request_type_value
    request_type
  end

  # Returns "classroom", "student", "child", or "unknown"
  def request_type_name
    REQUEST_TYPES.key(request_type)&.to_s || "unknown"
  end
end
