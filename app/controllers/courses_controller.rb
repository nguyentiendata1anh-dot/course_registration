class CoursesController < ApplicationController
  # Thêm grades và update_grades vào danh sách cần tìm course trước
  before_action :set_course, only: [:show, :edit, :update, :destroy, :grades, :update_grades]
  
  # ====================================================
  # --- ADMIN SECTION (QUẢN TRỊ VIÊN) ---
  # ====================================================
  
  def index
    require_admin!
    @courses = Course.all
  end
  
  def show
    require_admin!
    # Mặc định admin bấm vào môn học sẽ vào trang sửa
    redirect_to edit_course_path(@course)
  end
  
  def new
    require_admin!
    @course = Course.new
  end
  
  def edit
    require_admin!
  end
  
  def create
    require_admin!
    @course = Course.new(course_params)
    
    if @course.save
      redirect_to admin_root_path, notice: "Môn học đã được tạo thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    require_admin!
    if @course.update(course_params)
      redirect_to admin_root_path, notice: "Môn học đã được cập nhật."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    require_admin!
    @course.destroy
    redirect_to admin_root_path, notice: "Môn học đã được xóa."
  end

  # --- TÍNH NĂNG SỔ ĐIỂM (GRADEBOOK) ---
  
  # 1. Hiển thị danh sách sinh viên để nhập điểm
  def grades
    require_admin!
    # Lấy danh sách sinh viên, sắp xếp theo email cho dễ tìm
    @enrollments = @course.enrollments.includes(:user).order("users.email ASC")
  end

  # 2. Xử lý lưu điểm (Chuyên cần, Giữa kỳ, Cuối kỳ)
  def update_grades
    require_admin!
    
    if params[:enrollments_grades].present?
      count = 0
      # Lặp qua từng sinh viên được gửi lên từ form
      params[:enrollments_grades].each do |id, scores|
        enrollment = @course.enrollments.find(id)
        
        # Cập nhật 3 đầu điểm (Model sẽ tự tính Tổng kết & Điểm chữ)
        if enrollment.update(
             attendance_score: scores[:attendance_score],
             midterm_score: scores[:midterm_score],
             final_score: scores[:final_score]
           )
           count += 1
        end
      end
      redirect_to grades_course_path(@course), notice: "Đã cập nhật điểm thành công cho #{count} sinh viên!"
    else
      redirect_to grades_course_path(@course), alert: "Không có dữ liệu điểm để lưu."
    end
  end

  # ====================================================
  # --- STUDENT SECTION (SINH VIÊN) ---
  # ====================================================
  
  def student_home
    require_student!
    @available_courses = Course.available
    @enrolled_courses = current_user.courses
    @reminders = Reminder.order(created_at: :desc).limit(5)
    @latest_reminder = Reminder.order(created_at: :desc).first
    
    # Tính tổng tín chỉ tích lũy (Chỉ tính các môn ĐÃ QUA - tức là có điểm tổng >= 4.0)
    # Lưu ý: total_score được tính tự động trong Model Enrollment
    @total_credits = current_user.enrollments.where('total_score >= ?', 4.0).joins(:course).sum('courses.credits')

    # Tính GPA thang 10 (Trung bình cộng có trọng số)
    enrolls = current_user.enrollments.includes(:course)
    total_points = 0.0
    total_credits_gpa = 0
    
    enrolls.each do |e|
      # Chỉ tính những môn đã có điểm tổng kết
      next unless e.total_score.present? && e.course
      
      credits = e.course.credits.to_i
      total_credits_gpa += credits
      total_points += e.total_score.to_f * credits
    end
    
    @gpa_10 = total_credits_gpa > 0 ? (total_points / total_credits_gpa).round(2) : 0.0
  end
  
  def my_courses
    require_student!
    @enrolled_courses = current_user.courses
    # Lấy các môn chưa đăng ký
    @available_courses = Course.available.where.not(id: @enrolled_courses.pluck(:id))
  end
  
  def student_schedule
    require_student!
    @enrolled_courses = current_user.courses
  end
  
  def student_results
    require_student!
    # Lấy danh sách điểm thi
    all_history = current_user.enrollments.with_cancelled.includes(:course)
    @enrollments = current_user.enrollments.joins(:course).order("courses.code ASC") # Các môn đang học để hiển thị (đã áp dụng default_scope)

    # --- TÍNH TOÁN GPA VÀ TÍN CHỈ (REFACTORED FROM VIEW) ---
    earned_points10 = 0.0
    @earned_credits = 0
    @failed_credits = 0
    @counted_credits = 0

    # Tính toán trên các môn đang active cho GPA và tín chỉ hiện tại
    @enrollments.each do |e|
      if e.total_score.present? && e.course
        credits = e.course.credits.to_i
        @counted_credits += credits
        earned_points10 += e.total_score.to_f * credits
        if e.passed?
          @earned_credits += e.completed_credits.to_i
        else
          # Chỉ tính tín chỉ trượt cho các môn đang active
          @failed_credits += credits
        end
      end
    end
    @gpa = @counted_credits > 0 ? (earned_points10 / @counted_credits) : 0.0

    # Tính toán "tổng tín chỉ đã từng trượt" từ toàn bộ lịch sử
    @accumulated_failed_enrollments = all_history.select { |e| e.total_score.present? && !e.passed? }
    @accumulated_failed_credits = @accumulated_failed_enrollments.sum { |e| e.course&.credits.to_i }
  end
  
  def student_profile
    require_student!
    @user = current_user
    @profile_requests = current_user.profile_requests.order(created_at: :desc)
    @profile_request = ProfileRequest.new
  end
  
  private
  
  def set_course
    @course = Course.find(params[:id])
  end
  
  def course_params
    # Permit đầy đủ các trường: Thông tin cơ bản + Lịch học (3 biến) + Tiên quyết + Mô tả
    params.require(:course).permit(
      :code, :name, :credits, :capacity, :room, :teacher_name,
      :description, :prerequisite,
      :day_of_week, :start_time, :end_time, # 3 biến quan trọng để xếp lịch
      :start_date, :end_date, :term_id, :deadline # Hạn đăng ký
    )
  end
end