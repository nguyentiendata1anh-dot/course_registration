class CreateSections < ActiveRecord::Migration[8.1]
  def change
    create_table :sections do |t|
      t.references :course, null: false, foreign_key: true, index: true
      t.string :code
      t.integer :capacity
      t.string :teacher_name
      t.string :room
      t.string :schedule
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
