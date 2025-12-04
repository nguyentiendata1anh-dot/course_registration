class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Quan hệ
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :profile_requests, dependent: :destroy
  has_one_attached :avatar
  
  # Enum cho role
  enum :role, { student: 0, admin: 1 }, default: :student
  
  # Validation
  validates :student_id, uniqueness: true, allow_nil: true

  # Phương thức helper
  def admin?
    role == 'admin'
  end
  
  def student?
    role == 'student'
  end
  
  # Phương thức lấy display name
  def display_name
    full_name.presence || email.split('@').first
  end
end