class BookSeries < ApplicationRecord
  has_many :books

  validates :title, presence: true
end
