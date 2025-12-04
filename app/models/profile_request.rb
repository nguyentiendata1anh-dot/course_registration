class ProfileRequest < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar

  # Sửa enum đúng cú pháp Rails 7+
  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: 0

  # Scope để lấy các yêu cầu đang chờ
  scope :pending, -> { where(status: :pending) }
  scope :approved, -> { where(status: :approved) }
  scope :rejected, -> { where(status: :rejected) }

  # Phương thức để trả về mô tả yêu cầu
  def request_description
    return "Cập nhật thông tin" unless user
    
    changes = []
    changes << "họ tên" if full_name.present? && full_name != user.full_name
    changes << "số điện thoại" if phone.present? && phone != user.phone
    changes << "địa chỉ" if address.present? && address != user.address
    changes << "ngày sinh" if dob.present? && dob != user.dob
    changes << "ảnh đại diện" if avatar.attached?
    
    if changes.any?
      "Cập nhật #{changes.join(', ')}"
    else
      "Cập nhật thông tin"
    end
  end

  # Alias để tương thích với code cũ
  alias_method :field, :request_description
  alias_method :request_type, :request_description
  
  # Phương thức hỗ trợ để lấy danh sách thay đổi
  def changed_fields
    return [] unless user
    
    fields = []
    fields << "full_name" if full_name.present? && full_name != user.full_name
    fields << "phone" if phone.present? && phone != user.phone
    fields << "address" if address.present? && address != user.address
    fields << "dob" if dob.present? && dob != user.dob
    fields << "avatar" if avatar.attached?
    fields
  end
end