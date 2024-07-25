class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :title
      t.text :summary
      t.integer :quantity
      t.date :publication_date
      t.references :category, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true
      t.references :book_series, null: false, foreign_key: true

      t.timestamps
    end
  end
end
