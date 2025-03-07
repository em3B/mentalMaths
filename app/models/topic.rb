class Topic < ApplicationRecord
  has_many :questions, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validate :must_have_questions

  private

  def must_have_questions
    errors.add(:base, "Topic must have at least one question") if questions.empty?
  end
end
