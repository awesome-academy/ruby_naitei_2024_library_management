class Admin::ApplicationController < ApplicationController
  load_and_authorize_resource
  layout "admin"
  before_action :is_admin_role?
end
