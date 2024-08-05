class ChangeGenderType < ActiveRecord::Migration[7.0]
  def up
    change_column :authors, :gender, :integer, using: "gender::integer"
    change_column :users, :gender, :integer, using: "gender::integer"
  end

  def down
    change_column :authors, :gender, :boolean, using: "gender::boolean"
    change_column :users, :gender, :boolean, using: "gender::boolean"
  end
end
