require "rails_helper"

RSpec.describe RequestsController, type: :controller do
  include SessionsHelper
  let(:account_with_user){create(:account, :with_user, confirmed_at: Time.current)}
  let!(:request_record) { create(:request, user: account_with_user.user) }
  let!(:borrow_book) { create(:borrow_book, request: request_record, borrow_date: 2.days.from_now) }
  let(:invalid_request_params) { { borrow_date: 1.day.ago, user_id: account_with_user.user.id, status: "pending", description: "Mô tả yêu cầu" } }
  let(:selected_books) { [create(:book)] }

  before do
    sign_in account_with_user
  end

  describe "GET #new" do

    it "assigns a new request to @request" do
      get :new
      expect(assigns(:request)).to be_a_new(Request)
    end

    it "assigns @books to the books in user cart" do
      book = create(:book)
      account_with_user.user.books_in_carts << book
      get :new
      expect(assigns(:books)).to eq([book])
    end
  end

  describe "GET #index" do

    it "assigns @requests and @total_requests" do
      get :index
      expect(assigns(:requests)).not_to be_nil
      expect(assigns(:requests)).to eq([request_record])
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "responds successfully" do
      get :index
      expect(response).to have_http_status(:success)
    end
    context "when the borrow date is valid" do
      it "assigns @q with the ransacked requests" do
        get :index, params: { q: { borrow_date_gteq: 1.day.from_now, borrow_date_lteq: 3.days.from_now } }
        expect(assigns(:q)).to be_a_kind_of(Ransack::Search)
      end

      it "assigns @requests with the filtered requests" do
        get :index, params: { q: { borrow_date_gteq: 1.day.from_now, borrow_date_lteq: 3.days.from_now } }
        expect(assigns(:requests)).not_to be_nil
        expect(assigns(:requests)).to include(request_record)
      end

      it "renders the index template" do
        get :index, params: { q: { borrow_date_gteq: 1.day.from_now, borrow_date_lteq: 3.days.from_now } }
        expect(response).to render_template(:index)
      end
    end

    context "when the borrow date is invalid" do
      it "handles wrong borrow dates and sets a flash alert" do
        get :index, params: { q: { borrow_date_gteq: 3.days.from_now, borrow_date_lteq: 1.day.from_now } }
        expect(flash.now[:alert]).to eq(I18n.t("noti.validate_borrow_date"))
        expect(assigns(:requests)).to be_empty # Assuming no requests are assigned
      end
    end

    context "when there are no requests" do
      it "assigns an empty @requests" do
        get :index
        expect(assigns(:requests)).not_to be_nil
        expect(assigns(:requests)).to eq([request_record])
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested request to @request" do
      get :edit, params: { id: request_record.id }
      expect(assigns(:request)).to eq(request_record)
    end
  end

  describe "POST #create" do
    let(:book) { create(:book) }
    let(:valid_attributes) {
      {
        status: "pending",
        description: "Test description",
        borrow_date: Date.tomorrow
      }
    }
    context "when the borrow date is invalid" do
      it "sets a warning flash message and redirects to new request path" do
        post :create, params: { request: invalid_request_params, selected_books: selected_books }

        expect(response).to redirect_to(new_request_path)
        expect(flash[:warning]).to eq(I18n.t("noti.empty_request_noti"))
      end
    end

    context "when the account is banned" do
      before do
        allow_any_instance_of(User).to receive_message_chain(:account, :ban?).and_return(true)
      end

      it "redirects to new request path with a danger flash message" do
        post :create, params: { request: attributes_for(:request) }
        expect(flash[:danger]).to eq(I18n.t("noti.banned_message"))
        expect(response).to redirect_to new_request_path
      end
    end

    context "when the request is valid" do
      let(:request_params) { attributes_for(:request, borrow_date: 1.day.from_now) }

      before do
        allow_any_instance_of(RequestsController).to receive(:fetch_selected_books).and_return([book])
      end

      it "creates a new request and redirects to requests path with a success flash message" do
        post :create, params: { request: request_params }
        expect(flash[:success]).to eq(I18n.t("noti.request_success_noti"))
        expect(response).to redirect_to requests_path
      end
    end

    context "when the borrow date is invalid" do
      let(:request_params) { attributes_for(:request, borrow_date: 1.day.ago) }

      it "redirects to new request path with a warning flash message" do
        post :create, params: { request: request_params }
        expect(flash[:warning]).to eq(I18n.t("noti.empty_request_noti"))
        expect(response).to redirect_to new_request_path
      end
    end
  end

  describe "PATCH #update" do
    context "when the update is successful" do
      it "updates the request and responds with turbo stream" do
        patch :update, params: { id: request_record.id, request: { description: "Updated description", status: "approved" }, format: :turbo_stream }
        request_record.reload
        expect(request_record.status).to eq("approved")
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end

    context "when the update to rejected is successful" do
      it "updates the request status to rejected and responds with turbo stream" do
        patch :update, params: { id: request_record.id, request: { description: "Updated description", status: "rejected" }, format: :turbo_stream }

        request_record.reload
        expect(request_record.status).to eq("rejected")
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end

    context "when the update fails" do
      before do
        allow_any_instance_of(Request).to receive(:update).and_return(false)
      end

      it "redirects to the request path with a danger flash message" do
        patch :update, params: { id: request_record.id, request: { description: "" } }
        expect(response).to redirect_to request_path(request_record)
        expect(flash[:danger]).to eq(I18n.t("noti.update_fail"))
      end
    end

  end

  describe "GET #show" do
    context "when the request is found" do
      it "assigns the request to @request" do
        get :show, params: { id: request_record.id }
        expect(assigns(:request)).to eq(request_record)
      end
    end

    context "when the request is not found" do
      it "redirects to requests path with an error flash message" do
        get :show, params: { id: "non-existing-id" }
        expect(flash[:error]).to eq(I18n.t("noti.request_not_found"))
        expect(response).to redirect_to requests_path
      end
    end
  end
end
