class CreateBorrowBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :borrow_books do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.references :request, null: false, foreign_key: true
      t.date :borrow_date
      t.date :return_date
      t.boolean :is_borrow

      t.timestamps
    end
  end
end
