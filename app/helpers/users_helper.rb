module UsersHelper
  def gender_options_for_select
    User.genders.map{|key, _| [key.capitalize, key]}
  end

  def status_options_for_select
    [[t("user.index.title"), ""], [t("user.banned.title"), "banned"]]
  end

  def user_avatar user, size = Settings.avatar.list_size
    image_url = user.profile_url.presence || "default_avatar.png"
    image_tag image_url, size:, class: "w-16 h-16 rounded-full"
  end

  def user_button_name
    case params[:status].to_s
    when "banned"
      t("user.banned.activate")
    when "overdue"
      t("user.overdue.ban")
    else
      ""
    end
  end

  def user_button_path
    "#"
  end

  def user_button_active?
    params[:status].present?
  end
end
