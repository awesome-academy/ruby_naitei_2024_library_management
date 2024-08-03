class Admin::AuthorsController < Admin::ApplicationController
  def index
    @pagy, @authors = pagy Author.order_by_name,
                           items: Settings.authors_per_page
  end
end
