class Api::V1::UsersController < ApplicationController
  protect_from_forgery unless: ->{request.format.json?}
  before_action :load_user, only: %i(show update)

  def show
    render json: @user, status: :ok
  end

  def create
    @user = build_user_with_account

    return if @user.nil?

    if @user.save
      render json: {user: @user, message: t("noti.successful_creation")},
             status: :created
    else
      render json: {errors: @user.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: {user: @user, message: t("noti.user_update_success")},
             status: :ok
    else
      render json: {errors: @user.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  private

  def load_user
    @user = User.find_by(id: params[:id])
    render json: {error: t("noti.not_found")}, status: :not_found unless @user
  end

  def user_params
    params.require(:user).permit(User::VALID_ATTRIBUTES)
  end

  def build_user_with_account
    current_account = Account.find_by(id: params[:account_id])
    return current_account.build_user user_params if current_account.present?

    handle_account_not_found
    nil
  end

  def handle_account_not_found
    render json: {error: t("noti.account_not_found")}, status: :not_found
  end
end
