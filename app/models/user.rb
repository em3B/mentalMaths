class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable,
       authentication_keys: [ :login, :role ]

  ROLES = %w[student teacher family].freeze

  attr_accessor :plain_password

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
  belongs_to :classroom, optional: true

  # Teacher owns classrooms
  has_many :classrooms, foreign_key: :teacher_id, dependent: :destroy

  # Scores
  has_many :scores

  # Homework
  has_many :assigned_topics
  has_many :assigned_topics_as_assigner, class_name: "AssignedTopic", foreign_key: "assigned_by_id"
  has_many :topics_assigned, through: :assigned_topics, source: :topic

  validates :username, presence: true, uniqueness: { conditions: -> { where.not(classroom_id: nil) } }
  validates :email, presence: true, unless: :student_or_child?
  validates :email, uniqueness: true, allow_blank: true

  def learner?
    student? && (created_by_family? || classroom.present?)
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

  def student_or_child?
    student? || parent.present?
  end
end
