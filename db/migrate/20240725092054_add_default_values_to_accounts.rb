class AddDefaultValuesToAccounts < ActiveRecord::Migration[7.0]
  def change
    change_column_default :accounts, :is_admin, false
    change_column_default :accounts, :status, 0
  end
end
