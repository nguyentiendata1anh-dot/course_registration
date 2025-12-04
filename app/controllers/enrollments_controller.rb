class EnrollmentsController < ApplicationController
  before_action :require_student!
  before_action :set_course_or_section, only: [:create]
  before_action :set_enrollment, only: [:destroy]

  def create
    # create enrollment for a specific section if present, otherwise for the course
    if @section.present?
      @enrollment = current_user.enrollments.new(section: @section, course: @course)
    else
      @enrollment = current_user.enrollments.new(course: @course)
    end

    # determine expired and capacity checks (prefer section if available)
    if @section.present?
      if @section.expired?
        redirect_back fallback_location: student_courses_path, alert: "Đã hết hạn đăng ký lớp này." and return
      elsif @section.remaining_capacity <= 0
        redirect_back fallback_location: student_courses_path, alert: "Lớp đã đầy." and return
      elsif current_user.enrollments.exists?(section: @section)
        redirect_back fallback_location: student_courses_path, alert: "Bạn đã đăng ký lớp này." and return
      end
    else
      if @course.expired?
        redirect_back fallback_location: student_courses_path, alert: "Đã hết hạn đăng ký môn học này." and return
      elsif !@course.has_capacity?
        redirect_back fallback_location: student_courses_path, alert: "Môn học đã đầy." and return
      elsif current_user.enrollments.exists?(course: @course)
        redirect_back fallback_location: student_courses_path, alert: "Bạn đã đăng ký môn học này." and return
      end
    end

    if @course.prerequisite.present?
      # Prerequisite stored as course code; ensure student has passed that course
      prereq_course = Course.find_by(code: @course.prerequisite)
      if prereq_course.nil?
        # If referenced prerequisite not found, block registration to be safe
        redirect_back fallback_location: student_courses_path, alert: "Môn tiên quyết không hợp lệ. Liên hệ quản trị viên."
        return
      end

      prereq_enrollment = current_user.enrollments.find_by(course: prereq_course)
      if prereq_enrollment&.passed?
        # Prerequisite is satisfied, allow registration
        if @enrollment.save
          redirect_to student_courses_path, notice: "Đã đăng ký môn học #{@course.code}."
        else
          redirect_back fallback_location: student_courses_path, alert: @enrollment.errors.full_messages.first
        end
      else
        redirect_back fallback_location: student_courses_path, alert: "Bạn chưa hoàn thành môn tiên quyết: #{prereq_course.code} - #{prereq_course.name}. Không thể đăng ký."
      end
    else
      # Prevent normal re-registration: if user has any prior enrollment for this course that was passed, block
      prior_enrollments = current_user.enrollments.where(course: @course).where.not(id: @enrollment.id)
      if prior_enrollments.where('total_score IS NOT NULL AND total_score >= ?', 4.0).exists?
        redirect_back fallback_location: student_courses_path, alert: "Bạn đã hoàn thành môn này trước đó, không thể đăng ký lại (trừ khi là đăng ký học lại do điểm)." and return
      end

      if @enrollment.save
        redirect_to student_courses_path, notice: "Đã đăng ký môn học #{@course.code}."
      else
        redirect_back fallback_location: student_courses_path, alert: @enrollment.errors.full_messages.first
      end
    end
  end

  def destroy
    course = @enrollment.course

    if course.expired?
      # Cho phép xóa để đăng ký lại nếu điểm cuối cùng thuộc D, D+ hoặc F
      letter = @enrollment.respond_to?(:letter_grade) ? @enrollment.letter_grade : nil
      if %w[D D+ F].include?(letter)
        @enrollment.destroy
        redirect_to student_courses_path, notice: "Đã xóa kết quả để đăng ký lại môn #{course.code}."
      else
        redirect_to student_courses_path, alert: "Đã hết hạn hủy đăng ký môn học này."
      end
    else
      @enrollment.destroy
      redirect_to student_courses_path, notice: "Đã hủy đăng ký môn học #{course.code}."
    end
  end

  private

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