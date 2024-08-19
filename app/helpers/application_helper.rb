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
      new_user_path, admin_root_path,
      admin_users_path, admin_accounts_path,
      admin_books_path
    ]
    excluded_paths.include?(request.path) || flash[:danger]
  end
end
