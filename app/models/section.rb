class Section < ApplicationRecord
  belongs_to :course
  has_many :enrollments, dependent: :destroy

  validates :capacity, numericality: { greater_than: 0 }, allow_nil: true

  def remaining_capacity
    capacity.to_i - enrollments.count
  end

  def registration_close_date
    # prefer section-specific end_date if present, otherwise derive from course start_date
    if end_date.present?
      end_date.to_datetime
    elsif start_date.present?
      start_date.to_datetime + 7.days
    else
      course.deadline
    end
  end

  def expired?
    registration_close_date.present? && registration_close_date < Time.current
  end
end
