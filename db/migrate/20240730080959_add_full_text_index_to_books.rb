class AddFullTextIndexToBooks < ActiveRecord::Migration[7.0]
  def change
    add_index :books, [:title, :summary], type: :fulltext
  end
end
