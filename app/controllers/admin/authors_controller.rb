class Admin::AuthorsController < Admin::ApplicationController
  def index
    @pagy, @authors = pagy Author.order_by_name,
                           items: Settings.authors_per_page
  end

  def new
    @author = Author.new
  end

  def create
    @author = Author.new author_params
    if @author.save
      flash[:success] = t("noti.author.created_success")
      redirect_to admin_authors_path
    else
      flash[:warning] = t("noti.author.created_fail")
      redirect_to new_admin_author_path
    end
  end

  private

  def author_params
    params.require(:author).permit Author::AUTHOR_PARAMS
  end
end
