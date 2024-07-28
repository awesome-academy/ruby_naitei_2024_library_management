class BookSeries < ApplicationRecord
  has_many :books, dependent: :nullify

  validates :title, presence: true
end
