class CreateProfileRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name
      t.string :phone
      t.string :address
      t.date :dob
      t.text :reason
      t.integer :status

      t.timestamps
    end
  end
end
