class StaticPagesController < ApplicationController
  def home
    flash.now[:success] = t "noti.welcome"
  end
end
