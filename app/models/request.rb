class Request < ApplicationRecord
  enum status: { pending: 0, approved: 1, rejected: 2 }
  belongs_to :user
  has_many :borrow_books

  validates :status, presence: true
end
