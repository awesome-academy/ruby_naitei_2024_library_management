class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :remember_id, null: false
      t.integer :status, null: false, default: 0
      t.boolean :is_admin, null: false

      t.timestamps
    end
  end
end
