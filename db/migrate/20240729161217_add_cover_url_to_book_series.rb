class AddCoverUrlToBookSeries < ActiveRecord::Migration[7.0]
  def change
    add_column :book_series, :cover_url, :string
  end
end
