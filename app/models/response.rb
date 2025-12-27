class Response < ApplicationRecord
  belongs_to :question
  validates :value, presence: true
  belongs_to :user
end
