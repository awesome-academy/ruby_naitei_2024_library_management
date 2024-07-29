class BorrowBook < ApplicationRecord
  belongs_to :user
  belongs_to :book
  belongs_to :request

  validates :borrow_date, :is_borrow, presence: true

  scope :overdue, (lambda do
                     where("borrow_date < ? AND is_borrow = ?",
                           Settings.day_7.days.ago.to_date, true)
                   end)
end
