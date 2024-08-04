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
end
