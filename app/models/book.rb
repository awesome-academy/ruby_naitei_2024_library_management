class Book < ApplicationRecord
  belongs_to :category
  belongs_to :author
  belongs_to :book_series, optional: true
  has_one :book_inventory, dependent: :destroy
  has_many :borrow_books, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, :summary, :quantity, :publication_date, presence: true
end
