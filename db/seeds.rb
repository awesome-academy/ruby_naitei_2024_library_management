require "json"
require "faker"

# Load JSON files
books_file_path = Rails.root.join("db","books.json")
authors_file_path = Rails.root.join("db","authors.json")
categories_file_path = Rails.root.join("db","categories.json")
books_series_file_path = Rails.root.join("db","book_series.json")

books_file = File.read(books_file_path)
authors_file = File.read(authors_file_path)
categories_file = File.read(categories_file_path)
books_series_file = File.read(books_series_file_path)

books = JSON.parse(books_file)
authors = JSON.parse(authors_file)
categories = JSON.parse(categories_file)
books_series = JSON.parse(books_series_file)

# Seed categories
categories.each do |category|
  parent = Category.create!(name: category["name"], description: category["description"])
  category["subcategories"].each do |subcategory|
    Category.create!(name: subcategory["name"], description: subcategory["description"], parent_id: parent.id)
  end
end


# Seed authors
authors.each do |author|
  Author.create!(
    name: author["name"],
    birth: author["birth"],
    gender: author["gender"],
    bio: author["bio"],
    nationality: author["nationality"],
    profile_url: author["profile_url"]
  )
end

# Seed books

books_list = []
books.each do |item|
  book = Book.create(
    title: item["name"],
    summary: item["description"],
    quantity: rand(1..10),
    publication_date: Faker::Date.between(from: "2000-01-01", to: "2024-12-31"),
    category_id: rand(1..18),
    author_id: rand(1..20),
    book_series_id: nil,
    cover_url: item["book_cover"]
  )

  books_list << book
end

books_list.each do |book|
  BookInventory.create(
    book_id: book.id,
    available_quantity: rand(1..10)
  )
end

# Seed book series

books_series.each do |series|
  book_series_details = BookSeries.create!(
    title: series["title"],
    description: series["description"]
  )

  series["books"].each do |book|
    Book.create!(
      title: book["title"],
      summary: book["summary"],
      quantity: rand(1..10),
      publication_date: book["publication_date"],
      category_id: series["category_id"],
      author_id: series["author_id"],
      book_series_id: book_series_details.id,
      cover_url: book["image_url"]
    )
  end
end
admin_account = Account.create!(
  email: "admin@gmail.com",
  password: "admin123",
  status: 0,
  is_admin: 1
)

# Tạo tài khoản và người dùng giả
50.times do
  account = Account.create!(
    email: Faker::Internet.unique.email,
    password: "password",
    status: 0,
    is_admin: false
  )

  User.create!(
    citizen_id: Faker::Number.number(digits: 12),
    account_id: account.id,
    name: Faker::Name.name,
    birth: Faker::Date.between(from: "1970-01-01", to: "2010-12-31"),
    gender: [1, 0].sample,
    phone: Faker::PhoneNumber.unique.cell_phone,
    address: Faker::Address.full_address,
    profile_url: "default_avatar.png",
  )
end

# Tạo dữ liệu cho requests
request1 = Request.create!(user_id: 5, status: 1)
request2 = Request.create!(user_id: 6, status: 1)
request3 = Request.create!(user_id: 7, status: 1)

# Tạo dữ liệu cho borrow_books
BorrowBook.create!(user_id: 5, book_id: 1, request_id: request1.id, borrow_date: 10.days.ago, return_date: nil, is_borrow: true)
BorrowBook.create!(user_id: 6, book_id: 2, request_id: request2.id, borrow_date: 15.days.ago, return_date: nil, is_borrow: true)
BorrowBook.create!(user_id: 7, book_id: 3, request_id: request3.id, borrow_date: 20.days.ago, return_date: nil, is_borrow: true)
