class AuthorsController < ApplicationController
  authorize_resource
  def index
    all_authors = Author.order_by_name
    @pagy, @authors = pagy all_authors.order_by_name
    @total_authors = all_authors.order_by_name.count
  end

  def show
    @author = Author.find params[:id]
    @total_books = @author.books.count
    @pagy, @books = pagy @author.books
  end
end
