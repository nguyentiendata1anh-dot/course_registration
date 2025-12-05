class EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course_or_section, only: [:create]
  before_action :set_enrollment, only: [:destroy]

  def create
    # 1. KHỞI TẠO
    if @section.present?
      @enrollment = current_user.enrollments.new(section: @section, course: @course)
    else
      @enrollment = current_user.enrollments.new(course: @course)
    end

    # 2. KIỂM TRA CƠ BẢN
    target_obj = @section || @course
    
    # Check nếu sinh viên có điểm F (Học lực yếu)
    if current_user.enrollments.where(letter_grade: 'F').exists?
      failed_courses = current_user.enrollments.where(letter_grade: 'F').joins(:course).pluck('courses.code').join(', ')
      redirect_back fallback_location: student_courses_path, alert: "Bạn đang có điểm F ở các môn: #{failed_courses}. Không thể đăng ký thêm." and return
    end

    # Check Hạn
    if target_obj.respond_to?(:expired?) && target_obj.expired?
      redirect_back fallback_location: student_courses_path, alert: "Đã hết hạn đăng ký môn này." and return
    end

    # Check Sĩ số
    max_cap = target_obj.respond_to?(:capacity) ? target_obj.capacity : 100
    if target_obj.enrollments.count >= (max_cap || 100)
      redirect_back fallback_location: student_courses_path, alert: "Lớp đã đầy." and return
    end

    # Check Đã đăng ký chưa (Tránh spam)
    if @section.present?
      if current_user.enrollments.exists?(section: @section)
        redirect_back fallback_location: student_courses_path, alert: "Bạn đã đăng ký lớp này rồi." and return
      end
    elsif current_user.enrollments.exists?(course: @course)
      redirect_back fallback_location: student_courses_path, alert: "Bạn đã đăng ký môn này rồi." and return
    end

    # ====================================================================
    # 3. KIỂM TRA TRÙNG LỊCH (ĐÃ SỬA LỖI "TRÙNG VỚI CHÍNH NÓ")
    # ====================================================================
    
    # Lấy thông tin môn MỚI (Đổi ra phút)
    new_day = target_obj.respond_to?(:day_of_week) ? target_obj.day_of_week.to_i : 0
    new_start_min = time_to_minutes(target_obj.respond_to?(:start_time) ? target_obj.start_time : nil)
    new_end_min   = time_to_minutes(target_obj.respond_to?(:end_time) ? target_obj.end_time : nil)

    # Chỉ chạy kiểm tra nếu môn MỚI có đủ dữ liệu lịch
    if new_day > 0 && new_start_min > 0 && new_end_min > 0
      
      current_user.enrollments.each do |enrol|
        # Lấy đối tượng môn ĐÃ ĐĂNG KÝ
        existing_obj = enrol.section || enrol.course
        next unless existing_obj 

        # >>> [QUAN TRỌNG] BỎ QUA NẾU LÀ CHÍNH MÔN ĐÓ (Hoặc cùng mã môn) <<<
        # Điều này giúp tránh lỗi "Môn A trùng lịch với Môn A"
        next if enrol.course_id == @course.id

        # Lấy thông tin môn CŨ
        ex_day = existing_obj.respond_to?(:day_of_week) ? existing_obj.day_of_week.to_i : 0
        
        # Chỉ so sánh nếu môn CŨ cũng có đủ dữ liệu
        if ex_day > 0
          ex_start_min = time_to_minutes(existing_obj.start_time)
          ex_end_min   = time_to_minutes(existing_obj.end_time)

          if ex_start_min > 0 && ex_end_min > 0
            # LOGIC SO SÁNH:
            # 1. Cùng Thứ
            # 2. Giao nhau: (StartA < EndB) && (EndA > StartB)
            if new_day == ex_day && (new_start_min < ex_end_min) && (new_end_min > ex_start_min)
              
              # Format giờ hiển thị
              time_str = "#{existing_obj.start_time.strftime('%H:%M')} - #{existing_obj.end_time.strftime('%H:%M')}"
              
              conflict_msg = "⛔ TRÙNG LỊCH! Trùng với môn #{enrol.course.code} (Thứ #{new_day}, #{time_str})"
              redirect_back fallback_location: student_courses_path, alert: conflict_msg and return
            end
          end
        end
      end
    end
    # ====================================================================

    # 4. KIỂM TRA TIÊN QUYẾT
    if @course.prerequisite.present?
      prereq_course = Course.find_by(code: @course.prerequisite)
      
      # Chỉ kiểm tra nếu môn tiên quyết thực sự tồn tại trong hệ thống
      if prereq_course
        # Tìm bản ghi đăng ký của môn tiên quyết
        prereq_enrollment = current_user.enrollments.find_by(course: prereq_course)
        # Kiểm tra xem đã ĐẠT môn tiên quyết chưa (chưa học hoặc đã trượt đều không được)
        unless prereq_enrollment&.passed?
          redirect_back fallback_location: student_courses_path, alert: "Bạn phải ĐẠT môn tiên quyết: #{prereq_course.code}." and return
        end
      end
    end

    # 5. LƯU
    if @enrollment.save
      redirect_to student_courses_path, notice: "Đăng ký thành công môn #{@course.code}."
    else
      redirect_back fallback_location: student_courses_path, alert: "Lỗi hệ thống: #{@enrollment.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    # Lấy đối tượng môn học hoặc lớp học phần từ enrollment
    target_obj = @enrollment.section || @enrollment.course

    # KIỂM TRA: Không cho hủy sau khi hết hạn đăng ký.
    # NGOẠI LỆ: Cho phép hủy nếu bị điểm 'F' để đăng ký học lại.
    is_expired = target_obj.respond_to?(:expired?) && target_obj.expired?
    has_f_grade = @enrollment.letter_grade == 'F'

    if is_expired && !has_f_grade
      redirect_to student_courses_path, alert: "Đã hết hạn đăng ký, không thể hủy môn '#{target_obj.name}'. (Chỉ được hủy nếu có điểm F)"
    else
      # Chuyển sang xóa mềm (soft delete)
      @enrollment.update(status: :cancelled)
      notice_message = "Đã hủy đăng ký môn '#{target_obj.name}'. Môn học này vẫn sẽ được lưu trong lịch sử học tập."
      redirect_to student_courses_path, notice: notice_message
    end
  end

  private

  # Hàm chuyển giờ thành phút (An toàn với nil)
  def time_to_minutes(time_val)
    return 0 unless time_val.present?
    time_val.hour * 60 + time_val.min
  end

  def set_course_or_section
    if params[:section_id].present?
      @section = Section.find(params[:section_id])
      @course = @section.course
    else
      @course = Course.find(params[:course_id])
      @section = nil
    end
  end

  def set_enrollment
    @enrollment = current_user.enrollments.find(params[:id])
  end
end