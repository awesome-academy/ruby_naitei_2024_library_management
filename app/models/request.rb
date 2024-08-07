class Request < ApplicationRecord
  enum status: {pending: 0, approved: 1, rejected: 2, cancel: 3}
  belongs_to :user
  has_many :borrow_books, dependent: :destroy

  validates :status, presence: true

  def send_email
    if approved?
      RequestMailer.with(request: self, user:).request_approved.deliver_now
    elsif rejected?
      RequestMailer.with(request: self, user:).rejection_email.deliver_now
    end
  end
  scope :filter_by_status, lambda {|status|
    return if status.blank?

    where(status:)
  }

  scope :newest_first, ->{order(created_at: :desc)}

  scope :search_by_book, lambda {|query|
    joins(borrow_books: :book).merge(Book.filter_by_search(query))
  }
  scope :pending_for_user, lambda {|user|
                             joins(:borrow_books).where(user:, status: :pending)
                           }
end
