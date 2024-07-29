class UsersController < ApplicationController
  before_action :check_account_and_redirect, only: :new

  def new
    @user = User.new
  end

  def create
    @user = build_user_with_account

    if @user.save
      handle_successful_creation
    else
      handle_failed_creation
    end
  end

  private

  def user_params
    params.require(:user).permit(User::VALID_ATTRIBUTES)
  end

  def build_user_with_account
    return current_account.build_user user_params if current_account.present?

    handle_account_not_found
  end

  def handle_successful_creation
    flash[:success] = t "noti.successful_creation"
    redirect_to root_path
  end

  def handle_failed_creation
    flash[:danger] = @user.errors.full_messages.to_sentence
    redirect_to new_user_path
  end

  def handle_account_not_found
    flash[:alert] = t "noti.account_not_found"
    redirect_to new_user_path
  end

  def handle_account_already_has_user
    flash[:alert] = t "noti.account_already_has_user"
    redirect_to root_path
  end

  def check_account_and_redirect
    return unless current_account&.user.present?

    handle_account_already_has_user
  end
end