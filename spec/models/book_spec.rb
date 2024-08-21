require "rails_helper"

RSpec.describe Book, type: :model do
  describe "associations" do
    it { should belong_to(:category) }
    it { should belong_to(:author) }
    it { should belong_to(:book_series).optional }
    it { should have_one(:book_inventory).dependent(:destroy) }
    it { should have_many(:borrow_books).dependent(:destroy) }
    it { should have_many(:favourites).dependent(:destroy) }
    it { should have_many(:ratings).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:carts).dependent(:destroy) }
    it { should have_many(:favourited_users).through(:favourites).dependent(:destroy) }
    it { should have_many(:cart_users).through(:carts).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:summary) }
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:publication_date) }
    it { should validate_presence_of(:cover_image) }
  end

  describe "scopes" do
    let!(:category) { create(:category) }
    let!(:book1) { create(:book, title: "Harry Potter 1", publication_date: "2023-01-01", category: category) }
    let!(:book2) { create(:book, title: "Harry Potter 2", publication_date: "2022-01-01", category: category) }

    describe "latest" do
      it "returns books ordered by publication_date desc" do
        expect(Book.latest).to eq([book1, book2])
      end
    end

    describe "oldest" do
      it "returns books ordered by publication_date asc" do
        expect(Book.oldest).to eq([book2, book1])
      end
    end

    describe "filter_by_category" do
      it "returns books filtered by category" do
        expect(Book.filter_by_category(category)).to match_array([book1, book2])
      end
    end
  end

  describe "callbacks" do
    context "after_save :create_or_update_book_inventory" do
      let!(:book) { create(:book, quantity: 5) }

      it "creates book_inventory with correct available_quantity" do
        expect(book.book_inventory).to be_present
        expect(book.book_inventory.available_quantity).to eq(5)
      end

      it "updates book_inventory when quantity changes" do
        book.update(quantity: 10)
        expect(book.book_inventory.available_quantity).to eq(10)
      end
    end
  end

  describe "borrowed for request" do
    let(:book) { create(:book) }
    let(:borrow_request) { create(:borrow_request) }
    let!(:borrow_book) { create(:borrow_book, book: book, request: borrow_request, is_borrow: true, return_date: Date.today) }

    it "returns correct borrowing information" do
      result = book.borrowed_for_request(borrow_request.id)
      expect(result[:is_borrow]).to be true
      expect(result[:returned_date]).to eq(Date.today)
    end
  end
end
