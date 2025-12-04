class ProfileRequestsController < ApplicationController
  before_action :check_admin, only: [:index, :approve, :reject]

  # --- SINH VIÊN ---
  def new
    require_student!
    @profile_request = current_user.profile_requests.new(
      full_name: current_user.full_name,
      phone: current_user.phone,
      address: current_user.address,
      dob: current_user.dob
    )
  end

  def create
    require_student!
    @profile_request = current_user.profile_requests.new(request_params)
    @profile_request.status = :pending

    if @profile_request.save
      redirect_to student_profile_path, notice: "Đã gửi yêu cầu thay đổi thông tin."
    else
      @user = current_user
      @profile_requests = current_user.profile_requests.order(created_at: :desc)
      render 'courses/student_profile'
    end
  end

  # --- ADMIN ---
  def index
    require_admin!
    @requests = ProfileRequest.where(status: 0).order(created_at: :desc)
  end

  def approve
    require_admin!
    request = ProfileRequest.find(params[:id])
    user = request.user

    # Cập nhật thông tin
    user.update(full_name: request.full_name, phone: request.phone, 
                address: request.address, dob: request.dob)

    # Cập nhật Avatar
    if request.avatar.attached?
      user.avatar.attach(request.avatar.blob)
    end

    request.update(status: 1)
    redirect_to admin_root_path, notice: "Đã duyệt yêu cầu."
  end

  def reject
    require_admin!
    request = ProfileRequest.find(params[:id])
    request.update(status: 2)
    redirect_to admin_root_path, notice: "Đã từ chối."
  end

  private
  
  def request_params
    params.require(:profile_request).permit(:full_name, :phone, :address, :dob, :reason, :avatar)
  end
  
  def check_admin
    redirect_to root_path, alert: "Không có quyền" unless current_user.admin?
  end
end