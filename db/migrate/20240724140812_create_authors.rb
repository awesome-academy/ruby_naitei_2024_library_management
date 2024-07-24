class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.date :birth
      t.boolean :gender
      t.string :bio
      t.string :nationality
      t.string :profile_url

      t.timestamps
    end
  end
end
