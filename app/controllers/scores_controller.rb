class ScoresController < ApplicationController
  before_action :require_admin!
  
  def index
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @enrollments = @user.enrollments.includes(:course)
    else
      # List all students with simple aggregates
      @students = User.order(:email)
    end
  end
  
  def update
    @enrollment = Enrollment.find(params[:id])
    if @enrollment.update(score_params)
      redirect_to admin_scores_path(user_id: @enrollment.user_id), notice: "Cập nhật điểm thành công!"
    else
      redirect_to admin_scores_path(user_id: @enrollment.user_id), alert: "Lỗi khi cập nhật điểm!"
    end
  end
  
  private
  
  def score_params
    params.require(:enrollment).permit(:attendance_score, :midterm_exam_score, :final_exam_score)
  end
end
