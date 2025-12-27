class School < ApplicationRecord
  has_many :users
  has_many :school_invitations, dependent: :destroy

  validates :name, presence: true
  validates :contact_email, presence: true

  # Optional: require address too if you want
  # validates :address, presence: true

  # ensure contact_email looks like an email
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def active_subscription?
    billing_status.in?(%w[active trialing]) &&
      (subscription_ends_at.nil? || subscription_ends_at > Time.current)
  end

  def seats_used
    users.where(role: "teacher").count
  end

  def seats_available?
    seat_limit.to_i > users.where(role: "teacher").count
  end
end
