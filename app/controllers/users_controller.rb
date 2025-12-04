class UsersController < ApplicationController
  before_action :require_admin!, except: [:index]
  
  # Dashboard admin
  def index
    require_admin!
    
    @users = User.all
    @pending_count = ProfileRequest.where(status: 0).count
    @pending_requests = ProfileRequest.where(status: 0).includes(:user).limit(10)
    @recent_reminders = Reminder.order(created_at: :desc).limit(10)
    @reminder = Reminder.new
  end
  
  # Tạo tài khoản mới
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_root_path, notice: "Đã tạo tài khoản #{@user.email}"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # Xóa tài khoản
  def destroy
    @user = User.find(params[:id])
    if @user != current_user
      @user.destroy
      redirect_to admin_root_path, notice: "Đã xóa người dùng."
    else
      redirect_to admin_root_path, alert: "Không thể tự xóa chính mình!"
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role, :full_name, :phone, :student_id, :major, :dob, :address)
  end
end