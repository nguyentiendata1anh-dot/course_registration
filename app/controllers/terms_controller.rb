class TermsController < ApplicationController
  before_action :require_admin!
  before_action :set_term, only: [:edit, :update, :destroy]

  def index
    @terms = Term.all.order(start_date: :desc)
  end

  def new
    @term = Term.new
  end

  def create
    @term = Term.new(term_params)
    if @term.save
      redirect_to admin_root_path, notice: "Kỳ học được tạo thành công."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @term.update(term_params)
      redirect_to admin_root_path, notice: "Kỳ học được cập nhật thành công."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @term.destroy
    redirect_to admin_root_path, notice: "Kỳ học được xóa thành công."
  end

  private

  def set_term
    @term = Term.find(params[:id])
  end

  def term_params
    params.require(:term).permit(:name, :start_date, :end_date)
  end
end
