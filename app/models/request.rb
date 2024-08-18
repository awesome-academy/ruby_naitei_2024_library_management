class Request < ApplicationRecord
  enum status: {pending: 0, approved: 1, rejected: 2, cancel: 3,
                all_returned: 4}
  belongs_to :user
  has_many :borrow_books, dependent: :destroy
  has_many :books, through: :borrow_books

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
  scope :with_user_name, (lambda do
    joins(:user)
      .select("requests.*, users.name as user_name")
  end)
  scope :with_borrow_info, (lambda do
    joins(:borrow_books)
      .select("requests.*, COUNT(borrow_books.id) as book_quantity,
        MIN(borrow_books.borrow_date) as borrow_date")
      .group("requests.id")
  end)

  ransacker :user_name do
    Arel.sql("users.name")
  end

  ransacker :book_quantity do
    Arel.sql("(
      SELECT COUNT(*)
      FROM borrow_books
      WHERE request_id = requests.id)")
  end

  # Ransacker for borrow_date
  ransacker :borrow_date do
    Arel.sql("(
      SELECT borrow_date
      FROM borrow_books
      WHERE request_id = requests.id
      ORDER BY borrow_date ASC
      LIMIT 1)")
  end

  ransacker :id do
    Arel.sql("CONVERT(`#{table_name}`.`id`, CHAR(8))")
  end

  class << self
    def ransackable_attributes _auth_object = nil
      %w(created_at description id status updated_at user_id user_name
          book_quantity borrow_date borrow_date_eq)
    end

    def ransackable_associations _auth_object = nil
      %w(books borrow_books user)
    end

    def borrow_date_eq date_string
      where(borrow_date: Date.parse(date_string))
    rescue ArgumentError
      none
    end
  end
end
