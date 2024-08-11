class RatingsController < ApplicationController
  include SessionsHelper
  before_action :authenticate_user
  before_action :check_user_request
  def create
    @book = Book.find rating_params[:book_id]
    @rating = Rating.find_or_initialize_by(user_id: @current_user.id,
                                           book_id: @book.id)
    @rating.rating = rating_params[:rating]

    if @rating.save
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    else
      flash[:danger] = t "noti.rating_fail"
      redirect_to @book
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:book_id, :rating)
  end

  def check_user_request
    a = @current_user.borrow_books.find_by(book_id: rating_params[:id])
    return if a&.return_date

    flash[:warning] = t "noti.rating_authorization"
    redirect_to request.referer
  end
end
