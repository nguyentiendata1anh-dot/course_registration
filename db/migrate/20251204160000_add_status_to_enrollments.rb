class AddStatusToEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :status, :integer, default: 0, null: false
    add_index :enrollments, :status
  end
end