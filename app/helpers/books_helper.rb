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
end
