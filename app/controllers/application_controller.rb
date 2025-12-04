class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  
  protected
  
  # Kiểm tra nếu user là admin
  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Bạn không có quyền truy cập trang này!"
    end
  end
  
  # Kiểm tra nếu user là student
  def require_student!
    unless current_user&.student?
      redirect_to root_path, alert: "Bạn không có quyền truy cập trang này!"
    end
  end
  
  # Redirect sau khi đăng nhập
  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      student_dashboard_path
    end
  end
  
  # Redirect sau khi đăng xuất
  def after_sign_out_path_for(resource)
    root_path
  end
end