class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :section, optional: true

  # --- ENUMS ---
  enum :status, { active: 0, cancelled: 1 }

  # --- VALIDATIONS ---
  validates :attendance_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  validates :midterm_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  validates :final_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  validate :unique_enrollment_for_user

  # --- SCOPES ---
  default_scope { where(status: :active) } # Mặc định chỉ lấy các đăng ký đang hoạt động
  scope :with_cancelled, -> { unscope(where: :status) } # Lấy tất cả, bao gồm cả đã hủy

  # --- CALLBACKS (Tự động tính điểm trước khi lưu) ---
  before_save :calculate_all_grades

  # --- PHƯƠNG THỨC HỖ TRỢ ---
  
  # Kiểm tra ĐẠT (Theo quy chế tín chỉ thường là >= 4.0 hệ 10 hoặc điểm D)
  def passed?
    total_score.present? && total_score >= 4.0
  end

  # Kiểm tra có phải học lại không (Trượt)
  def is_retake_course?
    total_score.present? && total_score < 4.0
  end

  # Tính số tín chỉ tích lũy (Nếu trượt thì = 0)
  def completed_credits
    passed? ? course.credits : 0
  end

  private

  # Hàm tính toán trung tâm
  def calculate_all_grades
    # Chỉ tính khi CÓ ĐỦ 3 đầu điểm (Chuyên cần, Giữa kỳ, Cuối kỳ)
    if attendance_score.present? && midterm_score.present? && final_score.present?
      
      # 1. Tính tổng kết hệ 10 (20% - 20% - 60%)
      raw_total = (attendance_score * 0.2) + (midterm_score * 0.2) + (final_score * 0.6)
      self.total_score = raw_total.round(1)

      # 2. Quy đổi sang Điểm Chữ và Hệ 4 (Thang điểm chuẩn VNU)
      if self.total_score >= 9.0
        self.letter_grade = 'A+'
      elsif self.total_score >= 8.5
        self.letter_grade = 'A'
        self.score_4 = 4.0
      elsif self.total_score >= 8.0
        self.letter_grade = 'B+'
        self.score_4 = 3.5
      elsif self.total_score >= 7.0
        self.letter_grade = 'B'
        self.score_4 = 3.0
      elsif self.total_score >= 6.5
        self.letter_grade = 'C+'
        self.score_4 = 2.5
      elsif self.total_score >= 5.5
        self.letter_grade = 'C'
        self.score_4 = 2.0
      elsif self.total_score >= 5.0
        self.letter_grade = 'D+'
        self.score_4 = 1.5
      elsif self.total_score >= 4.0
        self.letter_grade = 'D'
        self.score_4 = 1.0
      else
        self.letter_grade = 'F'
        self.score_4 = 0.0
      end
    end
  end

  def unique_enrollment_for_user
    # Logic kiểm tra trùng môn/lớp
    scope = Enrollment.where(user_id: user_id).where.not(id: id)

    if section_id.present?
      errors.add(:base, "Bạn đã đăng ký lớp này rồi") if scope.where(section_id: section_id).exists?
    elsif course_id.present?
      errors.add(:base, "Bạn đã đăng ký môn học này rồi") if scope.where(course_id: course_id).exists?
    end
  end
end