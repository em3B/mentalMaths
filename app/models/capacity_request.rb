class CapacityRequest < ApplicationRecord
  belongs_to :user

  # Define allowed request types manually
  REQUEST_TYPES = {
    classroom: 0,
    student: 1,
    child: 2
  }

  validates :request_type, presence: true, inclusion: { in: REQUEST_TYPES.values }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :reason, presence: true

  # Convenience helper methods
  def request_type_symbol
    REQUEST_TYPES.key(request_type_value)
  end

  def request_type_value
    REQUEST_TYPES[request_type.to_sym]
  end

  def request_type_name
    REQUEST_TYPES.key(request_type).to_s
  end
end
