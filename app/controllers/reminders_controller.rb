class RemindersController < ApplicationController
  before_action :require_admin!, only: [:create, :destroy]
  
  def create
    @reminder = Reminder.new(reminder_params)
    
    if @reminder.save
      redirect_to admin_root_path, notice: "Đã đăng thông báo."
    else
      redirect_to admin_root_path, alert: "Lỗi: #{@reminder.errors.full_messages.first}"
    end
  end

  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy
    redirect_to admin_root_path, notice: "Đã xóa thông báo."
  end

  private

  def reminder_params
    params.require(:reminder).permit(:title, :content)
  end
end