class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course, optional: true
  belongs_to :section, optional: true
  
  # Validations
  validate :unique_enrollment_for_user
  
  # Track if this is a retake course
  attr_accessor :is_retake
  
  # Tính điểm tổng kết theo công thức: Chuyên cần 20% + Thi giữa kỳ 20% + Thi cuối kỳ 60%
  def calculate_total_score
    return nil unless attendance_score.present? && midterm_exam_score.present? && final_exam_score.present?
    
    (attendance_score * 0.2 + midterm_exam_score * 0.2 + final_exam_score * 0.6).round(2)
  end
  
  # Hook tự động tính điểm tổng kết khi save
  before_save :auto_calculate_total_score
  
  def auto_calculate_total_score
    self.total_score = calculate_total_score
  end
  
  # Phương thức lấy điểm chữ
  def letter_grade
    total = total_score
    return nil unless total
    
    case total
    when 9.0..10.0 then 'A'
    when 8.5..8.9 then 'A'
    when 7.0..8.4 then 'B'
    when 5.5..6.9 then 'C'
    when 4.0..5.4 then 'D'
    else 'F'
    end
  end
  
  # Phương thức kiểm tra đạt/không đạt (tối thiểu 4.0)
  def passed?
    total_score.present? && total_score >= 4.0
  end
  
  # Phương thức kiểm tra môn học này có phải học lại không (điểm F - < 4.0)
  def is_retake_course?
    total_score.present? && total_score < 4.0
  end
  
  # Phương thức trả về tín chỉ hoàn thành (chỉ tính nếu đạt)
  def completed_credits
    if passed?
      (section.present? ? section.course.credits : course.credits)
    else
      0
    end
  end

  private

  def unique_enrollment_for_user
    if section_id.present?
      if Enrollment.where(user_id: user_id, section_id: section_id).where.not(id: id).exists?
        errors.add(:base, "đã đăng ký lớp này")
      end
    elsif course_id.present?
      if Enrollment.where(user_id: user_id, course_id: course_id).where.not(id: id).exists?
        errors.add(:base, "đã đăng ký môn học này")
      end
    end
  end
end