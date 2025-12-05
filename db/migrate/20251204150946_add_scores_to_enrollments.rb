class AddScoresToEnrollments < ActiveRecord::Migration[8.1]
  def change
    # Thêm các cột điểm nếu chúng chưa tồn tại
    add_column :enrollments, :attendance_score, :float unless column_exists?(:enrollments, :attendance_score)
    add_column :enrollments, :midterm_score, :float unless column_exists?(:enrollments, :midterm_score)
    add_column :enrollments, :final_score, :float unless column_exists?(:enrollments, :final_score)
    add_column :enrollments, :total_score, :float unless column_exists?(:enrollments, :total_score)
    add_column :enrollments, :score_4, :float unless column_exists?(:enrollments, :score_4)
    add_column :enrollments, :letter_grade, :string unless column_exists?(:enrollments, :letter_grade)
  end
end
