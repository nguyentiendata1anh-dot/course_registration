class Reminder < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :content, presence: true
  
  # Scope
  scope :recent, -> { order(created_at: :desc).limit(10) }
end