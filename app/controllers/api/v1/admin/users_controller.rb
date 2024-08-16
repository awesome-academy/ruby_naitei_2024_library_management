class Api::V1::Admin::UsersController < ApplicationController
  include Pagy::Backend
  protect_from_forgery unless: ->{request.format.json?}
  before_action :load_user, only: :due_reminder

  def index
    @q = User.ransack(params[:q])
    @pagy, @users = pagy @q.result(distinct: true)
                           .includes(:account)
                           .includes(:borrow_books)
                           .filter_by_status(params[:filter_by_status])
                           .order(Arel.sql(order_clause)),
                         items: Settings.user_per_page

    render json: {
      users: @users.as_json(include: [:account, :borrow_books]),
      pagy: pagination_metadata(@pagy)
    }
  end

  def due_reminder
    @user.send_due_reminder
    render json: {message: t("due_reminder_success", user_name: @user.name)},
           status: :ok
  end

  private

  def order_clause
    if params.dig(:q, :s).present?
      allowed_sorts = %w(name borrowing_count borrowed_count)
      sort_param = params.dig(:q, :s)

      if allowed_sorts.include?(sort_param)
        "#{sort_param} ASC NULLS LAST"
      else
        "created_at DESC"
      end
    else
      "created_at DESC"
    end
  end

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user

    render json: {error: t("noti.not_found")}, status: :not_found
  end

  def pagination_metadata pagy
    {
      count: pagy.count,
      page: pagy.page,
      items: pagy.vars[:items],
      pages: pagy.pages
    }
  end
end
