class AddDetailsToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :room, :string
    add_column :courses, :schedule, :string
    add_column :courses, :deadline, :datetime
  end
end
