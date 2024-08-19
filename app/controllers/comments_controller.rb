class CommentsController < ApplicationController
  load_and_authorize_resource

  include Pagy::Backend
  before_action :find_book
  before_action :find_comment, only: %i(edit update)

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

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit; end

  def update
    @comment.update comment_params

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def reply
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def find_comment
    @comment = @book.comments.find params[:id]
    return if @comment

    flash[:danger] = t "noti.comment_not_found"
    redirect to @book
  end

  def find_book
    @book = Book.find params[:book_id]
    return if @book

    flash[:danger] = t "noti.book_not_found"
    redirect_to books_path
  end

  def comment_params
    params.require(:comment).permit(Comment::VALID_ATTRIBUTES)
  end

  def sort_comments
    @book.comments
         .includes(:user, :replies)
         .parent_comments
         .sorted_by(params[:sort])
  end
end
