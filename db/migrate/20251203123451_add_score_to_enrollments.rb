class AddScoreToEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :midterm_score, :float
    add_column :enrollments, :final_score, :float
  end
end
