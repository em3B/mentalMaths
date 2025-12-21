class User < ApplicationRecord
  belongs_to :school, optional: true
  # Devise modules
  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable,
       authentication_keys: [ :login, :role ]

  after_initialize :set_default_capacity_limits

  ROLES = %w[student teacher family admin].freeze

  SOFT_LIMIT_CHILDREN = 10

  validate :soft_limit_children, if: :family?, on: :create

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

  def admin?
    admin
  end

  def premium_teacher?
    teacher? && (
      (billing_status.in?(%w[active trialing]) && (subscription_ends_at.nil? || subscription_ends_at > Time.current)) ||
      (school.present? && school.active_subscription?)
    )
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

  # Limits for classroom, children, and students
  has_many :capacity_requests, dependent: :destroy

  validates :username, presence: true, uniqueness: { conditions: -> { where.not(classroom_id: nil) } }
  validates :email, presence: true, unless: :student_or_child?
  validates :email, uniqueness: true, allow_blank: true

  # =================
  # === Capacity Limits ===
  # =================

  # Ensure capacity_limits is always a hash
  after_initialize do
    self.capacity_limits ||= { "classroom" => 10, "student" => 40, "child" => 10 }
  end

  # Increment capacity for a given type
  def increment_capacity!(type, quantity)
    self.capacity_limits ||= { "classroom" => 10, "student" => 40, "child" => 10 }

    # Ensure key exists
    self.capacity_limits[type.to_s] ||= 0

    # Increment and persist
    self.capacity_limits[type.to_s] = self.capacity_limits[type.to_s].to_i + quantity.to_i
    save!
  end

  # Optional helper to fetch current limit
  def capacity_for(type_name)
    (capacity_limits || {})[type_name] || 0
  end

  def learner?
    student? && (created_by_family? || classroom.present?)
  end

  def login
    @login || (username.presence if student? && created_by_family?) || email
  end

  def login=(value)
    @login = value
  end

  def set_default_capacity_limits
    self.capacity_limits ||= {}
    self.capacity_limits["classroom"] ||= 10
    self.capacity_limits["student"]   ||= 40
    self.capacity_limits["child"]     ||= 10
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

  private

  def soft_limit_children
    return unless parent && parent.children.count >= SOFT_LIMIT_CHILDREN
    errors.add(:base, "You have reached the recommended limit of #{SOFT_LIMIT_CHILDREN} children. You can submit a request for more.")
  end
end
