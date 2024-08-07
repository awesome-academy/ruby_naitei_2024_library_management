module BorrowBooksHelper
  def status_borrow_options_for_select
    [[t("borrow_books.book.all"), ""], [t("borrow_books.book.borrowing"), true],
    [t("borrow_books.book.returned"), false]]
  end

  def borrow_status_class book
    if book.is_borrow
      "bg-blue-500 text-white"
    elsif book.request.approved?
      "bg-green-500 text-white"
    else
      "bg-red-500 text-white"
    end
  end

  def status book
    if book.is_borrow
      t "borrow_books.book.borrowing"
    elsif book.request.approved?
      t "borrow_books.book.returned"
    else
      t "book.status.book.#{book.request.status}"
    end
  end
end
