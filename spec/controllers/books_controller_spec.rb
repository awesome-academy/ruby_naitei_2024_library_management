require "rails_helper"

RSpec.describe BooksController, type: :controller do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:book) { create(:book, category: category) }
  let(:author) { create(:author) }

  describe "GET #index" do
    context "without search keywords" do
      it "assigns @books and @total_books" do
        get :index
        expect(assigns(:books)).not_to be_nil
        expect(assigns(:total_books)).to eq(assigns(:books).size)
      end

      it "paginates the books" do
        get :index
        expect(assigns(:pagy)).to be_a(Pagy)
      end

      it "responds successfully with an HTTP 200 status code" do
        get :index
        expect(response).to be_successful
        expect(response).to have_http_status(:ok)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context "with search keywords" do
      it "assigns @keywords and @total_authors" do
        get :index, params: { header_search: { title_or_summary_cont: "search_term" } }
        expect(assigns(:keywords)).to eq("search_term")
        expect(assigns(:total_authors)).to eq(assigns(:authors).size)
      end

      it "paginates the authors" do
        get :index, params: { header_search: { title_or_summary_cont: "search_term" } }
        expect(assigns(:pagy2)).to be_a(Pagy)
      end
    end

    context "when no books are found" do
      before do
        # Simulate an empty Active Record relation
        empty_relation = Book.none
        allow(Book).to receive(:ransack).and_return(double(result: empty_relation))
      end

      it "assigns an empty @books array" do
        get :index, params: { q: { title_or_summary_cont: "non_existent" } }
        expect(assigns(:books)).to be_empty
      end

      it "sets @total_books to 0" do
        get :index, params: { q: { title_or_summary_cont: "non_existent" } }
        expect(assigns(:total_books)).to eq(0)
      end
    end

    context "when an error occurs during search" do
      before do
        allow(Book).to receive(:ransack).and_raise(StandardError)
      end

      it "redirects to the index with an error flash message" do
        get :index, params: { q: { title_or_summary_cont: "search_term" } }
        expect(response).to redirect_to(root_path)
        expect(flash[:danger]).to eq(I18n.t("noti.search_error"))
      end
    end
  end


  describe "GET #show" do
    context "when the book exists" do
      it "assigns @book, @initial_rating, @comments, @favourite, and @related_books" do
        get :show, params: { id: book.id }
        expect(assigns(:book)).to eq(book)
        expect(assigns(:initial_rating)).to eq(0) # Assuming no rating exists
        expect(assigns(:comments)).to eq(book.comments)
        expect(assigns(:favourite)).to be_nil
        expect(assigns(:related_books)).not_to be_nil
      end

      it "responds successfully with an HTTP 200 status code" do
        get :show, params: { id: book.id }
        expect(response).to be_successful
        expect(response).to have_http_status(:ok)
      end

      it "renders the show template" do
        get :show, params: { id: book.id }
        expect(response).to render_template(:show)
      end
    end

    context "when the book does not exist" do
      it "redirects to the books index and sets a flash message" do
        get :show, params: { id: 0 }
        expect(response).to redirect_to(books_path)
        expect(flash[:danger]).to eq(I18n.t("noti.book_not_found"))
      end
    end
  end
end
