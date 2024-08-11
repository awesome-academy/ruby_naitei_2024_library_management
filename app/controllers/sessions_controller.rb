class SessionsController < Devise::SessionsController
  def after_sign_in_path_for _resource
    return admin_users_path if current_account.is_admin

    root_path
  end
end
