class BookSeries < ApplicationRecord
  has_many :books, dependent: :destroy

  validates :title, presence: true
end
