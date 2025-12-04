class Course < ApplicationRecord
  # Quan hệ
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  has_many :sections, dependent: :destroy
  belongs_to :term, optional: true
  
  # Enum cho ngày trong tuần
  enum :day_of_week, { monday: 0, tuesday: 1, wednesday: 2, thursday: 3, friday: 4, saturday: 5, sunday: 6 }, default: :monday
  
  # Validations
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :credits, presence: true, numericality: { greater_than: 0 }
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  # Tự động đặt deadline = start_date + 7 ngày
  before_validation :sync_deadline_with_start_date
  
  # Scope
  scope :available, -> { where('deadline > ? OR deadline IS NULL', Time.current) }
  
  # Phương thức kiểm tra còn chỗ trống
  def has_capacity?
    enrollments.count < capacity
  end
  
  # Phương thức lấy số chỗ còn lại
  def remaining_capacity
    capacity - enrollments.count
  end
  
  # Phương thức kiểm tra đã hết hạn đăng ký
  def expired?
    deadline.present? && deadline < Time.current
  end

  # Ngày kết thúc đăng ký (registration close) — mặc định là `deadline`
  def registration_close_date
    deadline
  end

  # Trạng thái còn mở đăng ký hay không
  def registration_open?
    !expired?
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    if end_date < start_date
      errors.add(:end_date, 'phải sau hoặc bằng ngày bắt đầu')
    end
  end

  def sync_deadline_with_start_date
    return if start_date.blank?
    self.deadline = start_date.to_datetime + 7.days
  end
end