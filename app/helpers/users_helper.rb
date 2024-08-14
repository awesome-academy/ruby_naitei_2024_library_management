module UsersHelper
  def gender_options_for_select
    User.genders.map{|key, _| [key.capitalize, key]}
  end

  def account_status_for_select
    Account.statuses.map{|key, value| [key.humanize, value]}
  end

  def status_options_for_select
    [[t("user.overdue.title"), "overdue"],
    [t("user.neardue.title"), "neardue"]]
  end

  def user_avatar user, size = Settings.avatar.list_size
    image_url = if user.profile_image.attached?
                  user.profile_image
                else
                  "default_avatar.png"
                end
    image_tag image_url, size:, class: "w-16 h-16 rounded-full"
  end

  def user_button_name
    case params[:status].to_s
    when "banned"
      t("user.banned.activate")
    when "overdue"
      t("user.overdue.ban")
    when "neardue"
      t("user.neardue.sent")
    else
      ""
    end
  end

  def user_button_path user
    case params[:status].to_s
    when "banned", "overdue"
      update_status_admin_account_path user.account
    when "neardue"
      due_reminder_admin_user_path user
    else
      ""
    end
  end

  def user_button_active?
    params[:status].present?
  end

  def account_status_button user
    if user.account.ban?
      button_to t("user.banned.activate"),
                update_status_admin_account_path(user.account),
                method: :post, data: {turbo_stream: true},
                class: "mr-2 p-3 py-1 mt-2 bg-transparent hover:bg-green-700
                  text-green-700 font-semibold hover:text-white border
                  border-green-700 hover:border-transparent rounded-md
                  font-medium"
    elsif user.account.active?
      button_to t("user.overdue.ban"),
                update_status_admin_account_path(user.account),
                method: :post, data: {turbo_stream: true},
                class: "mr-2 p-3 py-1 mt-2 bg-transparent hover:bg-red-700
                  text-red-700 font-semibold hover:text-white border
                  border-red-700 hover:border-transparent rounded-md
                  font-medium"
    end
  end
end
