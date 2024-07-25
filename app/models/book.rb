class Book < ApplicationRecord
  belongs_to :category
  belongs_to :author
  belongs_to :book_series, optional: true
  has_one :book_inventory
  has_many :borrow_books
  has_many :favorites
  has_many :ratings
  has_many :comments

  validates :title, :summary, :quantity, :publication_date, presence: true
end
