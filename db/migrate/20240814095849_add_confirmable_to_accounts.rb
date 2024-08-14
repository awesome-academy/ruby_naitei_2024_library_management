class AddConfirmableToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :confirmation_token, :string
    add_index :accounts, :confirmation_token
    add_column :accounts, :confirmed_at, :datetime
    add_column :accounts, :confirmation_sent_at, :datetime
    add_column :accounts, :unconfirmed_email, :string
  end
end
