require "rails_helper"

RSpec.describe User, type: :model do
  let(:account_with_user) { create(:account, confirmed_at: Time.current) }
  let(:user) { create(:user, account: account_with_user) }

  describe "associations" do
    it { should belong_to(:account) }
    it { should have_many(:borrow_books).dependent(:destroy) }
    it { should have_many(:requests).dependent(:destroy) }
    it { should have_many(:favourites).dependent(:destroy) }
    it { should have_many(:favourite_books).through(:favourites).source(:book) }
    it { should have_many(:ratings).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:author_followers).dependent(:destroy) }
    it { should have_many(:carts).dependent(:destroy) }
    it { should have_many(:books).through(:carts).dependent(:destroy) }
    it { should have_one_attached(:profile_image) }
  end

  describe "validations" do
    it { should validate_presence_of(:citizen_id) }
    it { should validate_length_of(:citizen_id).is_equal_to(Settings.digit_12) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(Settings.digit_50) }

    it { should validate_presence_of(:birth) }
    
    it { should validate_presence_of(:phone) }
    it { should validate_numericality_of(:phone) }
    it { should validate_length_of(:phone).is_at_least(Settings.digit_10).is_at_most(Settings.digit_15) }

    it { should validate_presence_of(:address) }
    it { should validate_length_of(:address).is_at_most(Settings.digit_255) }

    describe "custom validation: restrict_age" do
      context "when birth is less than 16 years ago" do
        let(:user) { build(:user, birth: 15.years.ago.to_date, account: account_with_user) }

        it "adds an error on birth" do
          user.valid?
          expect(user.errors[:birth]).to include(I18n.t("restrict_age"))
        end
      end

      context "when birth is more than 16 years ago" do
        let(:user) { build(:user, birth: 17.years.ago.to_date, account: account_with_user) }

        it "does not add an error on birth" do
          user.valid?
          expect(user.errors[:birth]).to be_empty
        end
      end
    end
  end

  describe "scopes" do
    let!(:banned_account) { create(:account, status: Settings.status.banned) }
    let!(:user_banned) { create(:user, account: banned_account) }
    let!(:book) { create(:book) }
    let!(:request) { create(:request) }

    describe ".banned" do
      it "returns users with banned accounts" do
        expect(User.banned).to include(user_banned)
      end

      it "does not return users with active accounts" do
        expect(User.banned).not_to include(user)
      end
    end

    describe ".overdue" do
      let!(:overdue_borrow_book) { create(:borrow_book, user: user, borrow_date: 8.days.ago, book: book, request: request) }

      it "returns users with overdue borrowed books" do
        expect(User.overdue).to include(user)
      end
    end

    describe ".neardue" do
      let!(:neardue_borrow_book) { create(:borrow_book, user: user, borrow_date: 6.days.ago) }

      it "returns users with near due borrowed books" do
        expect(User.neardue).to include(user)
      end
    end
  end

  describe "methods" do
    describe "#send_due_reminder" do
      before do
        create(:borrow_book, user: user, borrow_date: 6.days.ago)
      end
      it "sends a reminder email" do
        expect { user.send_due_reminder }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    describe "#books_in_carts" do
      let!(:book) { create(:book) }
      let!(:cart) { create(:cart, user: user, book: book) }

      it "returns books in the user\"s cart" do
        expect(user.books_in_carts).to include(book)
      end
    end
  end

  describe "class methods" do
    describe ".due_reminder" do
      it "sends due reminder emails to near due users" do
        allow(User).to receive(:neardue).and_return([user])
        expect(user).to receive(:send_due_reminder)
        User.due_reminder
      end
    end
  end
end
