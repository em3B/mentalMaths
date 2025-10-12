class CapacityRequestsController < ApplicationController
  before_action :authenticate_user!

  def new
    @capacity_request = CapacityRequest.new

    # Pre-fill from params safely
    @capacity_request.request_type = params[:request_type] if params[:request_type].present?
    @capacity_request.quantity = params[:quantity].to_i if params[:quantity].present? && params[:quantity].to_i > 0
  end

  def create
    @capacity_request = current_user.capacity_requests.new(capacity_request_params)

    if @capacity_request.save
      puts "📬 Sending mail for request ##{@capacity_request.id} (#{@capacity_request.request_type})"
      # ✅ Send email only AFTER saving (when it has an ID)
      CapacityRequestMailer.new_request_notification(@capacity_request).deliver_now
      redirect_to root_path, notice: "Your request has been submitted. We'll review it soon!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def capacity_request_params
    params.require(:capacity_request).permit(:request_type, :quantity, :reason, :additional_info)
  end
end
