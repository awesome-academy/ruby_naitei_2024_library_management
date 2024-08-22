class Admin::AccountsController < Admin::ApplicationController
  authorize_resource
  before_action :load_account, :is_admin_role?, only: %i(update update_status)

  def update_status
    if @account.toggle_status
      flash.now[:success] = t "noti.update_success"
    else
      flash.now[:danger] = t "noti.update_fail"
    end
    turbo_stream
  end

  private
  def load_account
    @account = Account.find_by(id: params[:id])
    return if @account

    flash[:danger] = t "noti.account_not_found"
    redirect_to admin_users_path
  end
end
