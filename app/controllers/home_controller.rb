class HomeController < ApplicationController
  # Trang chủ không yêu cầu đăng nhập
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    # Nếu đã đăng nhập, redirect đến trang tương ứng
    if user_signed_in?
      if current_user.admin?
        redirect_to admin_root_path
      else
        redirect_to student_dashboard_path
      end
    else
      # Hiển thị trang chủ công khai với form đăng nhập
      render 'index'
    end
  end
end