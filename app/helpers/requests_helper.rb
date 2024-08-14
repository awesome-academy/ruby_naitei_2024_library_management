module RequestsHelper
  def status_request_options_for_select
    options = Request.statuses.keys.map do |status|
      [t("requests.#{status}"), status]
    end
    [[t("requests.all"), ""]] + options
  end

  def status_class status
    case status
    when "pending"
      "bg-blue-500 text-white"
    when "approved"
      "bg-green-500 text-white"
    when "cancelled"
      "bg-purple-500 text-white"
    when "rejected"
      "bg-red-500 text-white"
    else
      "bg-orange-400 text-white"
    end
  end

  def status_icon status
    icon_class = case status
                 when "pending"
                   "bi bi-arrow-clockwise animate-spin"
                 when "approved"
                   "bi bi-check2-circle"
                 when "cancelled"
                   "bi bi-person-dash"
                 when "rejected"
                   "bi bi-x-circle"
                 else
                   "bi bi-exclamation-circle"
                 end
    content_tag(:i, "", class: icon_class)
  end

  def mark_returned_available request, book
    return false unless request.approved?

    borrow_info = book.borrowed_for_request(request.id)
    borrow_info[:is_borrow]
  end
end
