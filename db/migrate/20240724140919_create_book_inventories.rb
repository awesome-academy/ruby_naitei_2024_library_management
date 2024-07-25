class CreateBookInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :book_inventories do |t|
      t.references :book, null: false, foreign_key: true
      t.integer :available_quantity

      t.timestamps
    end
  end
end
