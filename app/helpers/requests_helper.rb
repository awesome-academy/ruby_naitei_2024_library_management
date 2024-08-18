module RequestsHelper
  def status_request_options_for_select
    options = Request.statuses.map do |status, value|
      [t("requests.#{status}"), value]
    end
    [[t("requests.all"), ""]] + options
  end

  def status_class status
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
      "bg-pink-400 text-white"
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
end
