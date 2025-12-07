class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user!

  def edit
    # Load current payment info if you store it (e.g., Stripe customer)
    @payment_method = current_user.try(:payment_method) || nil
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

  def create_subscription
    customer = Stripe::Customer.create({
      email: current_user.email,
      name: current_user.name,
      payment_method: params[:payment_method],
      invoice_settings: { default_payment_method: params[:payment_method] }
    })

    subscription = Stripe::Subscription.create({
      customer: customer.id,
      items: [ { price: "price_xxxxx" } ], # replace with your Stripe price ID
      expand: [ "latest_invoice.payment_intent" ]
    })

    current_user.update(
      stripe_customer_id: customer.id,
      stripe_subscription_id: subscription.id,
      billing_status: subscription.status,
      plan_name: "Basic Plan",
      subscription_ends_at: subscription.current_period_end
    )

    redirect_to profile_path, notice: "Subscription created!"
    rescue Stripe::CardError => e
      flash[:alert] = e.message
      render :edit
  end

  private

  def authorize_user!
    unless current_user.teacher? || current_user.family?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
