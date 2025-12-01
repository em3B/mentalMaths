class Admin::CapacityRequestsController < Admin::BaseController
  def index
    @capacity_requests = CapacityRequest.order(created_at: :desc)
  end
  def approve
    @capacity_request = CapacityRequest.find(params[:id])

    ActiveRecord::Base.transaction do
      # Update user's limit using capacity_limits json
      @capacity_request.user.increment_capacity!(
        @capacity_request.request_type_name,
        @capacity_request.quantity
      )

      # Mark request as approved
      @capacity_request.update!(status: "approved")
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@capacity_request) }
      format.html { redirect_to admin_dashboard_path, notice: "Request approved and limits updated." }
    end
  rescue => e
    redirect_to admin_dashboard_path, alert: "Failed to approve request: #{e.message}"
  end

  def decline
    @capacity_request = CapacityRequest.find(params[:id])
    @capacity_request.destroy

    CapacityRequestMailer.decline_notification(@capacity_request).deliver_later

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@capacity_request) }
      format.html { redirect_to admin_dashboard_path, alert: "Request declined and user notified." }
    end
  end
end
