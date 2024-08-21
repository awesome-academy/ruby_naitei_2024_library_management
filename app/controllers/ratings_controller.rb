class RatingsController < ApplicationController
  authorize_resource
  before_action :load_book
  before_action :authorize_rating
  def create
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

  def load_book
    @book = Book.find rating_params[:book_id]

    return if @book

    flash[:warning] = t "noti.book_not_found"
    redirect_to request.referer
  end

  def authorize_rating
    return unless @current_user.borrow_books
                               .find_by(book_id: @book.id)&.return_date.nil?

    flash[:warning] = t "noti.rating_authorization"
    redirect_to request.referer
  end
end
