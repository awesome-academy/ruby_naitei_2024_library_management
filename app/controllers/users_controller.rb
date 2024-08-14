class UsersController < ApplicationController
  load_and_authorize_resource
  before_action :check_account_and_redirect, only: :new
  before_action :load_user, :correct_user, only: %i(show edit update)
  def index
    @pagy, @users = pagy User.order_by_name.with_status(params[:status]),
                         items: Settings.users_per_page
  end

  def new
    @user = User.new
    @user.birth ||= 16.years.ago.to_date
  end

  def create
    @user = build_user_with_account

    if @user.save
      handle_successful_creation
    else
      handle_failed_creation
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t "noti.user_update_success"
      redirect_to @user
    else
      flash.now[:error] = t "noti.user_update_fail"
      render :edit
    end
  end

  private

  def correct_user
    return if @current_user == @user

    flash[:alert] = t "noti.permission_err"
    redirect_to root_path
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "noti.not_found"
    redirect_to root_path
  end

  def account_present?
    current_account.present?
  end

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
    flash[:danger] = @user.errors.full_messages[0]
    redirect_to new_user_path
  end

  def handle_account_not_found
    flash[:warning] = t "noti.account_not_found"
    redirect_to new_user_path
  end

  def handle_account_already_has_user
    flash[:warning] = t "noti.account_already_has_user"
    redirect_to root_path
  end

  def check_account_and_redirect
    redirect_to new_account_registration_path unless account_present?
    return if current_account&.user.blank?

    handle_account_already_has_user
  end
end
