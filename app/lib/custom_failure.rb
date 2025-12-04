class CustomFailure < Devise::FailureApp
  # Hàm này quy định: Nếu đăng nhập thất bại -> Chuyển hướng về trang chủ "/"
  def redirect_url
    "/"
  end

  # Ghi đè phương thức phản hồi để bắt buộc chuyển hướng thay vì render form mặc định
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end