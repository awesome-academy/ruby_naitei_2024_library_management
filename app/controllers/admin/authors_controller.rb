class Admin::AuthorsController < Admin::ApplicationController
  authorize_resource
  before_action :load_author, only: %i(edit update destroy)

  def index
    @q = Author.ransack params[:q], auth_object: current_account
    @pagy, @authors = pagy @q.result(distinct: true)
                             .includes(:books)
  end

  def new
    @author = Author.new
    @author.birth ||= Settings.birth_valid.years.ago.to_date
  end

  def create
    @author = Author.new author_params
    if @author.save
      flash[:success] = t("noti.author_created_success")
      redirect_to admin_authors_path
    else
      flash[:warning] = @author.errors.full_messages[0]
      redirect_to new_admin_author_path
    end
  end

  def edit; end

  def update
    if @author.update author_params
      flash[:success] = t "noti.author.updated_success"
      redirect_to admin_authors_path
    else
      flash.now[:warning] = t "noti.author.updated_fail"
      render :edit
    end
  end

  def destroy
    if @author.destroy
      flash[:success] = t "noti.author.deleted_success"
    else
      flash[:danger] = t "noti.author.deleted_fail"
    end
    redirect_to admin_authors_path
  end

  private

  def load_author
    @author = Author.find_by id: params[:id]
    return if @author

    flash[:danger] = t "noti.author.not_found"
    redirect_to admin_authors_path
  end

  def author_params
    params.require(:author).permit Author::AUTHOR_PARAMS
  end
end
