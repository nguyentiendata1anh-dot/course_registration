class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :code
      t.string :name
      t.text :description
      t.integer :credits
      t.integer :capacity

      t.timestamps
    end
  end
end
