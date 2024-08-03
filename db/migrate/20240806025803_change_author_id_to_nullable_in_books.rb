class ChangeAuthorIdToNullableInBooks < ActiveRecord::Migration[7.0]
  def change
    change_column_null :books, :author_id, true
  end
end
