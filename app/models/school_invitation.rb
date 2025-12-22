class SchoolInvitation < ApplicationRecord
  belongs_to :school

  before_validation :ensure_token, on: :create

  validates :email, presence: true
  validates :token, presence: true, uniqueness: true

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def accepted?
    accepted_at.present?
  end

  private

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end
end
