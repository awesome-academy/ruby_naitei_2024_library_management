module BooksHelper
  def book_cover_image book
    if book.cover_image.attached?
      link_to book_path(book), data: {turbo_frame: "_top"},
      class: "border-2 flex-1 h-full" do
        image_tag book.cover_image, alt: "cover", class: "w-full"
      end
    else
      content_tag(:div, class: "border-2 flex-1 h-full") do
        image_tag "default_cover_image.png", alt: "Default cover image",
        class: "w-full"
      end
    end
  end

  def is_returned? request, book
    status_title(request, book) == t("borrow_books.book.returned")
  end

  def year_options_for_select
    years = (1900..Date.current.year).to_a.reverse.map do |year|
      [year.to_s, Date.new(year, 1, 1)]
    end
    years.to_h
  end

  def rating_options_for_select
    [
      ["5 ⭐", "4.5-5.0"],
      ["4 ⭐", "3.5-4.49"],
      ["3 ⭐", "2.5-3.49"],
      ["2 ⭐", "1.5-2.49"],
      ["1 ⭐", "0.09-1.49"]
    ]
  end

  def status_title request, book
    if request.approved?
      borrow_info = book.borrowed_for_request(request.id)
      if borrow_info[:is_borrow]
        t "borrow_books.book.borrowing"
      else
        t "borrow_books.book.returned"
      end
    elsif request.all_returned?
      t "borrow_books.book.returned"
    else
      t "requests.#{request.status}"
    end
  end

  def book_status_icon request, book
    icon_class = case request.status
                 when "pending"
                   "bi bi-arrow-clockwise animate-spin"
                 when "approved"
                   if book.borrowed_for_request(request.id)[:is_borrow]
                     "bi bi-person"
                   else
                     "bi bi-check2-circle"
                   end
                 when "cancelled"
                   "bi bi-person-dash"
                 when "rejected"
                   "bi bi-x-circle"
                 else
                   "bi bi-exclamation-circle"
                 end
    content_tag(:i, "", class: icon_class)
  end
end
