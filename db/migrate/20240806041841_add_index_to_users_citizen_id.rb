class AddIndexToUsersCitizenId < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :citizen_id, unique: true
  end
end
