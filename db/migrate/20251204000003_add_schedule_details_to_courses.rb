class AddScheduleDetailsToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :day_of_week, :integer
    add_column :courses, :start_time, :time
    add_column :courses, :end_time, :time
  end
end
