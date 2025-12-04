class AddSectionIdToEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_reference :enrollments, :section, foreign_key: true, index: true, null: true
    # keep existing course_id for compatibility; apps can populate both
  end
end
