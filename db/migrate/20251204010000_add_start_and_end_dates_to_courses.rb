class AddStartAndEndDatesToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :start_date, :date
    add_column :courses, :end_date, :date
    add_index :courses, :start_date
    add_index :courses, :end_date
  end
end
