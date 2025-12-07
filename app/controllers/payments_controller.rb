class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user!

  def edit
    # Load current payment info if you store it (e.g., Stripe customer)
    @payment_method = current_user.payment_method
  end

  def update
    # Example: update Stripe payment method
    if current_user.update_payment_method(params[:payment_method])
      redirect_to profile_path, notice: "Payment method updated successfully."
    else
      flash.now[:alert] = "There was a problem updating your payment method."
      render :edit
    end
  end

  private

  def authorize_user!
    unless current_user.teacher? || current_user.family?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
