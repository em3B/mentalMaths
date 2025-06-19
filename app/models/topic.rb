class Topic < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :scores

  CATEGORIES = [ "Addition and Subtraction", "Multiplication", "Number Bonds", "Ten Frames", "Rainbow Pairs" ]

  validates :title, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  private
end
