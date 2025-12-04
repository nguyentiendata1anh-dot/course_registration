class UpdateEnrollmentsAddScoreColumns < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :attendance_score, :float, comment: "Chuyên cần"
    add_column :enrollments, :midterm_exam_score, :float, comment: "Thi giữa kỳ"
    add_column :enrollments, :final_exam_score, :float, comment: "Thi cuối kỳ"
    add_column :enrollments, :total_score, :float, comment: "Tổng điểm (tính từ công thức)"
  end
end
