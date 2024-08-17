class BookSeriesController < ApplicationController
  authorize_resource
  def show
    @book_series = BookSeries.find_by id: params[:id]
    return if @book_series

    flash[:danger] = t "noti.book_series_not_found"
    redirect_to root_path
  end
end
