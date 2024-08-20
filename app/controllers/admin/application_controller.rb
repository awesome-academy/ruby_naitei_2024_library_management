class Admin::ApplicationController < ApplicationController
  authorize_resource
  layout "admin"
  before_action :is_admin_role?
end
