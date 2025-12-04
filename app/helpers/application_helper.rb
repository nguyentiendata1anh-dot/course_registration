module ApplicationHelper
  def resource_name; :user; end
  def resource; @resource ||= User.new; end
  def devise_mapping; @devise_mapping ||= Devise.mappings[:user]; end

  # Tuition per credit (VND)
  def tuition_per_credit
    1_000_000
  end

  def format_tuition(amount)
    number_to_currency(amount, unit: "", precision: 0)
  end
end