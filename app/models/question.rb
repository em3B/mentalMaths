class Question < ApplicationRecord
  belongs_to :topic
  has_many :responses, dependent: :destroy

  validates :question_text, presence: true
  validates :correct_answer, presence: true
end
