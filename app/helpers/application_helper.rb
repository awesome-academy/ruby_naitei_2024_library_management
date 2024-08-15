module ApplicationHelper
  include Pagy::Frontend

  def full_title page_title
    base_title = t("base_title")
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def exclude_footer?
    excluded_paths = [
      new_account_session_path,
      new_account_registration_path,
      new_user_path,
      new_account_password_path,
      edit_account_password_path,
      account_password_path,
      new_account_unlock_path
    ]

    excluded_paths.any? do |path|
      path.include?(request.path)
    end || flash[:danger]
  end
end
