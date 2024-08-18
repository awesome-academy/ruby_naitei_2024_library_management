class Admin::UsersController < Admin::ApplicationController
  before_action :load_user, only: :due_reminder
  def index
    @q = User.ransack(params[:q])
    @pagy, @users = pagy @q.result(distinct: true)
                           .includes(:account)
                           .includes(:borrow_books)
                           .filter_by_status(params[:filter_by_status])
  end

  def due_reminder
    @user.send_due_reminder
    flash[:success] = t "due_reminder_success", user_name: @user.name
    redirect_to admin_users_path status: "neardue"
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "noti.not_found"
    redirect_to admin_users_path
  end
end
