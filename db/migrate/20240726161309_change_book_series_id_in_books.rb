class ChangeBookSeriesIdInBooks < ActiveRecord::Migration[7.0]
  def change
    change_column_null :books, :book_series_id, true
  end
end
