require "rails_helper"
RSpec.describe UsersController, type: :controller do
  let(:account_with_user){create(:account, :with_user, confirmed_at: Time.current)}
  let(:account_without_user){create(:account, confirmed_at: Time.current)}
  let(:user_params) do
    {
      citizen_id: Faker::Number.number(digits: 12),
      name: "Test User",
      birth: "1990-01-01",
      gender: "male",
      phone: "7699894321",
      address: "123 Test St",
    }
  end

  describe "GET #new" do
    context "when account has no user" do
      before do
        sign_in account_without_user
        get :new
      end

      it "renders the new template" do
        expect(response).to render_template(:new)
      end
    end

    context "when account already has a user" do
      before do
        sign_in account_with_user
        get :new
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end

      it "sets a flash message" do
        expect( flash[:warning]).to eq(I18n.t("noti.account_already_has_user"))
      end
    end

    context "when account is not present" do
      before do
        get :new
      end

      it "redirects to new account registration path" do
        expect(response).to redirect_to(new_account_session_path)
      end
    end
  end

  describe "POST #create" do
    before do
      sign_in account_without_user
    end

    context "with valid user params" do
      it "creates a new user" do
        expect {
          post :create, params:{user: user_params}
        }.to change(User, :count).by(1)
      end

      it "redirects to root path" do
        post :create, params:{user: user_params}
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid user params" do
      before do
        user_params[:citizen_id] = nil
      end

      it "does not create a new user" do
        expect {
          post :create, params:{user: user_params}
        }.not_to change(User, :count)
      end

      it "renders the new template again" do
        post :create, params:{user: user_params}
        expect(response).to redirect_to(new_user_path)
      end
    end
  end

  describe "GET #show" do
    before do
      sign_in account_with_user
    end
    context "when user exists" do
      it "renders the show template" do
        get :show, params:{id: account_with_user.user.id}
        expect(response).to render_template(:show)
      end
    end
    context "when user does not exist" do
      before do
        get :show, params:{id: -1}
      end
      it "redirects to the root path with a flash message" do
        expect(response).to redirect_to(root_path)
      end
      it "sets a flash message" do
        expect(flash[:danger]).to eq(I18n.t("noti.user_not_found"))
      end
    end

  end

  describe "GET #edit" do
    before do
      sign_in account_with_user
    end
    context "when user exists" do
      it "renders the edit template" do
        get :edit, params:{id: account_with_user.user.id}
        expect(response).to render_template(:edit)
      end
    end

    context "when user does not exist" do
      before do
        get :edit, params:{id: -1}
      end
      it "redirects to the root path with a flash message" do
        expect(response).to redirect_to(root_path)
      end
      it "sets a flash message" do
        expect(flash[:danger]).to eq(I18n.t("noti.user_not_found"))
      end
    end
  end

  describe "PATCH #update" do
    before do
      sign_in account_with_user
    end

    context "with valid params" do
      before do
        patch :update, params:{id: account_with_user.user.id, user:{name: "New Name"}}
      end
      it "updates the user" do
        account_with_user.reload
        expect(account_with_user.user.name).to eq("New Name")
      end

      it "redirects to the show page" do
        expect(response).to redirect_to(account_with_user.user)
      end

      it "sets a success flash message" do
        expect(flash[:success]).to eq(I18n.t("noti.user_update_success"))
      end
    end

    context "with invalid params" do
      before do
        patch :update, params:{id: account_with_user.user.id, user:{birth: "2022-10-10"}}
      end

      it "does not update the user" do
        account_with_user.reload
        expect(account_with_user.user.birth).not_to eq("2022-10-10")
      end

      it "re-renders the edit template" do
        expect(response).to render_template(:edit)
      end
    end

    context "when user does not exist" do
      before do
        patch :update, params:{id: -1, user:{name: "New Name"}}
      end

      it "redirects to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
