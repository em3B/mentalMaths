class Topic < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :scores
  has_many :assigned_topics
  has_many :students, through: :assigned_topics, source: :user

  CATEGORIES = [ "Addition and Subtraction", "Multiplication", "Number Bonds", "Ten Frames", "Rainbow Pairs", "Bar Models", "Number Blocks" ]

  validates :title, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  private
end
