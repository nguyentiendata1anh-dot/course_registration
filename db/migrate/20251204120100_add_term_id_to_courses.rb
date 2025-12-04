class AddTermIdToCourses < ActiveRecord::Migration[8.1]
  def change
    add_reference :courses, :term, foreign_key: true, index: true, null: true
  end
end
