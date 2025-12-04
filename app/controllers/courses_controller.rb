class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  
  # --- ADMIN SECTION ---
  def index
    require_admin!
    @courses = Course.all
  end
  
  def show
    require_admin!
    redirect_to edit_admin_course_path(@course)
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
  
  # --- STUDENT SECTION ---
  def student_home
    require_student!
    @available_courses = Course.available
    @enrolled_courses = current_user.courses
    @reminders = Reminder.order(created_at: :desc).limit(5)
    @latest_reminder = Reminder.order(created_at: :desc).first
    # Tính tổng tín chỉ của các môn đã đạt (total_score >= 4.0)
    @total_credits = current_user.enrollments.where('total_score >= ?', 4.0).joins(:course).sum('courses.credits')

    # GPA thang 10 (trung bình có trọng số theo tín chỉ)
    enrolls = current_user.enrollments.includes(:course)
    points10 = 0.0
    counted = 0
    enrolls.each do |e|
      next unless e.total_score.present? && e.course
      credits = e.course.credits.to_i
      counted += credits
      points10 += e.total_score.to_f * credits
    end
    @gpa_10 = counted > 0 ? (points10 / counted) : 0.0
  end
  
  def my_courses
    require_student!
    @enrolled_courses = current_user.courses
    @available_courses = Course.available.where.not(id: @enrolled_courses.pluck(:id))
  end
  
  def student_schedule
    require_student!
    @enrolled_courses = current_user.courses
  end
  
  def student_results
    require_student!
    @enrollments = current_user.enrollments.includes(:course)
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
    params.require(:course).permit(:code, :name, :credits, :capacity, :room, 
                                   :schedule, :teacher_name, :description, :prerequisite,
                                   :day_of_week, :start_time, :end_time, :start_date, :end_date)
  end
end