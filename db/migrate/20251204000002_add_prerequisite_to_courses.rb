class AddPrerequisiteToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :prerequisite, :text
  end
end
