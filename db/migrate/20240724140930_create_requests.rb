class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.bigint :user_id, null: false
      t.integer :status, null: false, default: 0
      t.string :description

      t.timestamps
    end
    add_foreign_key :requests, :users, column: :user_id
  end
end
