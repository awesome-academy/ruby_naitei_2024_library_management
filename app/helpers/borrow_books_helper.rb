module BorrowBooksHelper
  def status_borrow_options_for_select
    [[t("borrow_books.all"), ""], [t("borrow_books.borrowing"), true],
    [t("borrow_books.returned"), false]]
  end

  def borrow_status_class status
    if status
      "bg-blue-500 text-white"
    else
      "bg-green-500 text-white"
    end
  end
end
