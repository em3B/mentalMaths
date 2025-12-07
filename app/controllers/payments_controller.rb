class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user!

  def edit
    @payment_method = current_user.try(:payment_method) || nil
  end

  def update
    payment_method_id = params[:payment_method]

    # Create a Stripe Customer if not already created
    customer = if current_user.stripe_customer_id.present?
                 Stripe::Customer.retrieve(current_user.stripe_customer_id)
    else
                 Stripe::Customer.create(
                   email: current_user.email,
                   name: current_user.username,
                   payment_method: payment_method_id,
                   invoice_settings: { default_payment_method: payment_method_id }
                 )
    end

    # Create subscription (adjust price ID as needed)
    subscription = Stripe::Subscription.create(
      customer: customer.id,
      items: [ { price: "price_xxxxx" } ],
      expand: [ "latest_invoice.payment_intent" ]
    )

    # Update user record with Stripe info
    current_user.update(
      stripe_customer_id: customer.id,
      stripe_subscription_id: subscription.id,
      billing_status: subscription.status,
      plan_name: "Basic Plan",
      subscription_ends_at: Time.at(subscription.current_period_end),
      pending_payment: false
    )

    # Optionally sign in the user if they were just created
    sign_in(current_user) unless user_signed_in?

    redirect_to profile_path, notice: "Account created and subscription active!"
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
