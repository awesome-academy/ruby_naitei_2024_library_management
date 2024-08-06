class RenameFavoritesToFavourites < ActiveRecord::Migration[7.0]
  def change
    rename_table :favorites, :favourites
  end
end
