module BooksHelper
  def is_admin?
    current_account.present? && current_account.is_admin
  end

  def admin_add_book_link
    return unless is_admin?

    button_to t("books_page.add_book"), "#", class: "mr-8 h-10 px-4 py-2
    bg-primary text-primary-foreground hover:bg-primary/90 rounded-md
    font-medium"
  end
end
