class AddLockableToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :failed_attempts, :integer, default: 0, null: false
    add_column :accounts, :unlock_token, :string
    add_column :accounts, :locked_at, :datetime
    add_index :accounts, :unlock_token, unique: true
  end
end
