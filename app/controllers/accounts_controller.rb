class AccountsController < ApplicationController
  before_action :load_account, :is_admin_role?, only: %i(update update_status)
  def new
    @account = Account.new
  end

  def create
    @account = Account.new account_params
    if @account.save
      session[:account_id] = @account.id
      redirect_to new_user_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update_status
    if @account.toggle_status
      flash[:success] = t "noti.update_success"
    else
      flash[:danger] = t "noti.update_fail"
    end
    redirect_to users_path status: "banned"
  end

  private
  def account_params
    params.require(:account).permit(Account::VALID_ATTRIBUTES)
  end

  def load_account
    @account = Account.find_by(id: params[:id])
    return if @account

    flash[:danger] = t "noti.account_not_found"
    redirect_to users_path
  end
end
