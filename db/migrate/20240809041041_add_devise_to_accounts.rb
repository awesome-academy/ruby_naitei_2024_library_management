class AddDeviseToAccounts < ActiveRecord::Migration[7.0]
  def change
    # Rename the column from `password_digest` to `encrypted_password`
    rename_column :accounts, :password_digest, :encrypted_password

    # Add new columns
    add_column :accounts, :reset_password_token, :string
    add_column :accounts, :reset_password_sent_at, :datetime
    add_column :accounts, :remember_created_at, :datetime

    # Add indexes
    add_index :accounts, :reset_password_token, unique: true
    add_index :accounts, :email, unique: true
  end
end
