class BorrowBook < ApplicationRecord
  belongs_to :user
  belongs_to :book
  belongs_to :request

  validates :borrow_date, presence: true
  validates :is_borrow, inclusion: {in: [true, false]}

  scope :overdue, (lambda do
                     where("borrow_date < ? AND is_borrow = ?",
                           Settings.day_7.days.ago.to_date, true)
                   end)
  scope :near_due, (lambda do
                      where("DATEDIFF(CURDATE(), borrow_date) BETWEEN ? AND ?
                      AND is_borrow = ?", Settings.day_5, Settings.day_7, true)
                      .order("borrow_date ASC")
                    end)
  scope :count_for_user, lambda {|user_id|
                           where(user_id:, is_borrow: true).count
                         }
  scope :count_borrowed, (lambda do
    joins(:request)
    .where(is_borrow: false,
           requests: {status: Request.statuses[:approved]})
    .count
  end)
  scope :count_borrowing, (lambda do
    joins(:request)
    .where(is_borrow: true)
    .count
  end)
  scope :borrowed_by_user, lambda {|user|
                             where(user:, is_borrow: true)
                           }

  scope :borrowing_by_user, lambda {|user|
                              where(user:, is_borrow: true)
                            }
  scope :borrowed, ->{where(is_borrow: true)}

  scope :with_details, (lambda do
    joins(:book, :request, :user)
      .select("books.id, books.title, books.summary,
      borrow_books.borrow_date, borrow_books.return_date,
      borrow_books.user_id, users.name as user_name,
      borrow_books.request_id, borrow_books.is_borrow")
  end)

  scope :filter_by_search, lambda {|search_query|
    return if search_query.blank?

    where("MATCH(title, summary) AGAINST(?)", search_query)
  }

  scope :filter_by_status, lambda {|status|
    return if status.blank?

    where(is_borrow: status)
  }
end
