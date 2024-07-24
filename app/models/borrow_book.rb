class BorrowBook < ApplicationRecord
  belongs_to :user
  belongs_to :book
  belongs_to :request

  validates :borrow_date, :is_borrow, presence: true
end
