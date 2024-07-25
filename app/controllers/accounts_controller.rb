class AccountsController < ApplicationController
  def new
    @account = Account.new
  end

  def create
    @account = Account.new account_params
    if @account.save
      redirect_to new_user_path account_id: @account.id
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def account_params
    params.require(:account).permit(Account::VALID_ATTRIBUTES)
  end
end
