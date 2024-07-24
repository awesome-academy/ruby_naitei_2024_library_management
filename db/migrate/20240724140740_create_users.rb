class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :citizen_id
      t.references :account, null: false, foreign_key: true
      t.string :name
      t.date :birth
      t.boolean :gender
      t.string :phone
      t.string :address
      t.string :profile_url

      t.timestamps
    end
  end
end
