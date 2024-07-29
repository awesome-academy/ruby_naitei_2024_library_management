class AddCoverUrlToBooks < ActiveRecord::Migration[7.0]
  def change
    add_column :books, :cover_url, :string
  end
end
