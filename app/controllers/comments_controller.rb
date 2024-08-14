class CommentsController < ApplicationController
  include SessionsHelper
  include Pagy::Backend
  before_action :find_book
  before_action :authenticate_user, only: %i(create)

  def create
    @comment = @book.comments
                    .new comment_params.merge(user_id: @current_user.id)
    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    else
      flash[:danger] = t "noti.comment_fail"
      redirect_to @book
    end
  end

  def index
    @pagy, @comments = pagy sort_comments
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def find_book
    @book = Book.find params[:book_id]
    return if @book

    flash[:danger] = t "noti.book_not_found"
    redirect_to books_path
  end

  def comment_params
    params.require(:comment).permit(:comment_text, :book_id)
  end

  def sort_comments
    @book.comments.includes(:user).sorted_by params[:sort]
  end
end
