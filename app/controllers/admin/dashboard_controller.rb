class Admin::DashboardController < ApplicationController
  def index
    @users = User.all
    @capacity_requests = CapacityRequest.all
  end
end
