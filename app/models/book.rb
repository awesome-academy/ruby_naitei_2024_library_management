class Book < ApplicationRecord
  BOOK_PARAMS = %i(title summary quantity publication_date category_id
                   author_id description cover_image).freeze

  after_save :create_or_update_book_inventory

  belongs_to :category
  belongs_to :author
  belongs_to :book_series, optional: true
  has_one :book_inventory, dependent: :destroy
  has_many :borrow_books, dependent: :destroy
  has_many :favourites, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :users, through: :favourites, dependent: :destroy
  has_many :users, through: :carts, dependent: :destroy
  has_many :carts, dependent: :destroy
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

  scope :filter_related_books, lambda {|category_ids, bid|
    where(category_id: category_ids).where.not(id: bid).limit(4)
  }
  scope :in_user_cart, ->(user){where(id: user.books_in_carts.pluck(:id))}
  validates :title, :summary, :quantity, :publication_date, :cover_image,
            presence: true

  def borrowed_for_request request_id
    borrow_book = borrow_books.find_by(request_id:)
    {
      is_borrow: borrow_book&.is_borrow,
      returned_date: borrow_book&.return_date
    }
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
