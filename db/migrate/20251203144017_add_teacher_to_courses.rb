class AddTeacherToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :teacher_name, :string
  end
end
