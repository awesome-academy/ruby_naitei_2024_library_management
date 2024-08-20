class Author < ApplicationRecord
  AUTHOR_PARAMS = %i(name birth bio nationality gender profile_image).freeze
  has_many :books, dependent: :destroy
  has_many :author_followers, dependent: :destroy
  has_one_attached :profile_image

  enum gender: {male: 0, female: 1}

  scope :order_by_name, ->{order(name: :asc)}

  validates :name, length: {maximum: Settings.digit_50}
  validates :bio, length: {maximum: Settings.digit_255}
  validates :name, :birth, :bio, :nationality, :profile_image, presence: true

  ransacker :books_sum do
    Arel.sql("(SELECT SUM(books.quantity)
               FROM books WHERE books.author_id = authors.id)")
  end

  ransacker :borrowing_quantity do
    Arel.sql("(SELECT COUNT(borrow_books.id)
               FROM borrow_books
               INNER JOIN books ON borrow_books.book_id = books.id
               WHERE books.author_id = authors.id
               AND borrow_books.is_borrow = true)")
  end
  class << self
    def ransackable_attributes auth_object = nil
      if auth_object&.is_admin
        %w(name birth gender bio nationality books_sum borrowing_quantity
        created_at updated_at)
      else
        %w(name)
      end
    end

    def ransackable_associations _auth_object = nil
      %w(books author_followers)
    end
  end
end
