class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :full_name, :string
    add_column :users, :phone, :string
    add_column :users, :address, :string
    add_column :users, :dob, :date
  end
end
