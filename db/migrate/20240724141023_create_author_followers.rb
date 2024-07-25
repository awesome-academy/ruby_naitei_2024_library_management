class CreateAuthorFollowers < ActiveRecord::Migration[7.0]
  def change
    create_table :author_followers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true

      t.timestamps
    end
  end
end
