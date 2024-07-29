class BookSeries < ApplicationRecord
  has_many :books, dependent: :nullify

  scope :order_by_time, ->{order created_at: :desc}

  validates :title, presence: true
end
