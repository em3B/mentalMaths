class Question < ApplicationRecord
  belongs_to :topic
  has_many :responses, dependent: :destroy

  validates :question_text, presence: true
  validates :correct_answer, presence: true
  validate :must_have_response

  private

  def must_have_response
    errors.add(:base, "Each question must have at least one response") if responses.empty?
  end
end
