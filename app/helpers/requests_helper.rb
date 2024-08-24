module RequestsHelper
  def status_request_options_for_select
    Request.statuses.map do |status, value|
      [t("requests.#{status}"), value]
    end
  end

  def status_class status, is_book: false
    case status.to_sym
    when :pending
      "bg-blue-500 text-white"
    when :approved
      "bg-green-500 text-white"
    when :cancel
      "bg-orange-400 text-white"
    when :rejected
      "bg-red-500 text-white"
    when :all_returned
      if is_book
        "bg-green-500 text-white"
      else
        "bg-pink-400 text-white"
      end
    else
      "bg-orange-400 text-white"
    end
  end

  def status_icon status
    icon_class = case status.to_sym
                 when :pending
                   "bi bi-arrow-clockwise animate-spin"
                 when :approved
                   "bi bi-check2-circle"
                 when :cancel
                   "bi bi-person-dash"
                 when :rejected
                   "bi bi-x-circle"
                 when :all_returned
                   "bi bi-check-all"
                 else
                   "bi bi-exclamation-circle"
                 end
    content_tag(:i, "", class: icon_class)
  end

  def status_request_title status
    case status.to_sym
    when :pending
      t "requests.pending"
    when :approved
      t "requests.approved"
    when :cancel
      t "requests.cancel"
    when :rejected
      t "requests.rejected"
    when :all_returned
      t "requests.all_returned"
    else
      t "requests.unknown"
    end
  end

  def mark_returned_available request, book
    return false unless request.approved?

    borrow_info = book.borrowed_for_request(request.id)
    borrow_info[:is_borrow]
  end

  def request_qr_url request, is_admin
    if is_admin
      request_url(id: request.id)
    else
      search_param = {id_or_books_title_or_user_name_cont: request.id}.to_query
      admin_requests_url + "?q%5B#{search_param}%5D"
    end
  end

  def generate_qr_code request, is_admin
    qr = RQRCode::QRCode.new(request_qr_url(request, is_admin))
    qr.as_png(size: 300)
  end
end
