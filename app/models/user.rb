class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable,
       authentication_keys: [ :login, :role ]

  ROLES = %w[student teacher family].freeze

  def teacher?
    role == "teacher"
  end

  def family?
    role == "family"
  end

  def student?
    role == "student"
  end

  # =================
  # === Relations ===
  # =================

  # Parent-child (family -> children)
  has_many :children, class_name: "User", foreign_key: "parent_id", dependent: :nullify
  belongs_to :parent, class_name: "User", optional: true
  belongs_to :school, optional: true

  # Teacher owns classrooms
  has_many :classrooms, foreign_key: :teacher_id, dependent: :destroy

  # Students and Teachers can be in classrooms
  has_many :memberships
  has_many :enrolled_classrooms, through: :memberships, source: :classroom

  # Scores
  has_many :scores

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, unless: -> { student? && created_by_family? }
  validates :email, uniqueness: true, allow_blank: true
  validates :username, presence: true, uniqueness: true

  def learner?
    student? && (created_by_family? || enrolled_classrooms.any?)
  end

  def login
    @login || (username.presence if student? && created_by_family?) || email
  end

  # Override Devise to allow login by email or username
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    role       = conditions.delete(:role)
    login_val  = conditions.delete(:login)&.downcase

    where(role: role).where(
      [ "(lower(username) = :value OR lower(email) = :value)", { value: login_val } ]
    ).first
  end
end
