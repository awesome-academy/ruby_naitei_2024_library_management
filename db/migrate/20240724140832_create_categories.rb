class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.bigint :parent_id

      t.timestamps
    end

    add_foreign_key :categories, :categories, column: :parent_id, primary_key: :id
  end
end
