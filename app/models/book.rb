class Book < ApplicationRecord
  BOOK_PARAMS = %i(title summary quantity publication_date category_id
                   author_id description cover_image).freeze
  BOOK_RELATIONS = %i(borrow_books category author book_series ratings).freeze

  after_save :create_or_update_book_inventory

  belongs_to :category
  belongs_to :author
  belongs_to :book_series, optional: true
  has_one :book_inventory, dependent: :destroy
  has_many :borrow_books, dependent: :destroy
  has_many :favourites, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :favourited_users, through: :favourites, source: :user,
dependent: :destroy
  has_many :cart_users, through: :carts, source: :user, dependent: :destroy

  has_one_attached :cover_image

  scope :latest, ->{order(publication_date: :desc)}
  scope :oldest, ->{order(publication_date: :asc)}
  scope :default_order, ->{order(created_at: :asc)}
  scope :order_by_title, ->{order(title: :asc)}
  scope :filter_by_category, lambda {|category|
    return if category.blank?

    where(category_id: category&.subcategories&.pluck(:id)
                                .to_a << category.id)
  }

  scope :filter_by_search, lambda {|search_query|
    return if search_query.blank?

    where("MATCH(title, summary) AGAINST(?)", search_query)
  }

  scope :sorted_by, lambda {|sort_param|
    case sort_param
    when "latest"
      latest
    when "oldest"
      oldest
    when "highest_rating"
      joins(:ratings).group("books.id").order("AVG(ratings.rating) DESC")
    else
      default_order
    end
  }

  scope :borrowing_count, (lambda do
    joins(:borrow_books)
    .where(borrow_books: {is_borrow: true})
    .count
  end)
  scope :filter_related_books, lambda {|category_ids, bid|
    where(category_id: category_ids).where.not(id: bid).limit(4)
  }
  scope :in_user_cart, ->(user){where(id: user.books_in_carts.pluck(:id))}
  validates :title, :summary, :quantity, :publication_date, :cover_image,
            presence: true

  ransack_alias :search_by, :title_or_summary_cont

  def borrowed_for_request request_id
    borrow_book = borrow_books.find_by(request_id:)
    {
      is_borrow: borrow_book&.is_borrow,
      returned_date: borrow_book&.return_date
    }
  end

  ransacker :borrowing do
    Arel.sql("(SELECT COUNT(borrow_books.id)
               FROM borrow_books
               WHERE books.id = borrow_books.book_id
               AND borrow_books.is_borrow = true)")
  end

  ransacker :ratings do
    Arel.sql("(SELECT AVG(ratings.rating)
               FROM ratings
               WHERE ratings.book_id = books.id)")
  end

  ransacker :comments do
    Arel.sql("(SELECT COUNT(comments.id)
               FROM comments
               WHERE comments.book_id = books.id)")
  end

  class << self
    def ransackable_attributes auth_object = nil
      if auth_object&.is_admin
        %w(author_id book_series_id borrowing comments ratings category_id
          created_at description publication_date quantity summary title
          updated_at)
      else
        %w(summary title)
      end
    end

    def ransackable_associations _auth_object = nil
      %w(author book_inventory book_series borrow_books carts
         category comments cover_image_attachment cover_image_blob
         favourites ratings users)
    end

    def available? selected_books
      out_of_stock_books = selected_books.map do |book|
        inventory = book.book_inventory
        book.title if inventory.blank? || inventory.available_quantity <= 0
      end

      out_of_stock_books.compact
    end
  end
  private

  def create_or_update_book_inventory
    if book_inventory.present?
      book_inventory.update(available_quantity: quantity)
    else
      create_book_inventory(available_quantity: quantity)
    end
  end
end
