class ChangeRememberIdToBeNullableInAccounts < ActiveRecord::Migration[7.0]
  def change
    change_column_null :accounts, :remember_id, true
  end
end
