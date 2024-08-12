class AccountsController < Devise::RegistrationsController
  load_and_authorize_resource
  def after_sign_up_path_for _resource
    new_user_path
  end
end
