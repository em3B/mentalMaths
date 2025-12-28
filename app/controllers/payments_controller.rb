class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user!

  def edit
    # Billing page (subscribe / manage billing)
  end

  # POST /payments
  def create
    price_id = price_id_for(current_user)

    customer = if current_user.stripe_customer_id.present?
                 StripeCustomerWrapper.retrieve(current_user.stripe_customer_id)
    else
                 StripeCustomerWrapper.create(
                   email: current_user.email,
                   name: current_user.username
                 )
    end

    current_user.update!(stripe_customer_id: customer.id)

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      customer: customer.id,
      line_items: [ { price: price_id, quantity: 1 } ],
      metadata: { user_id: current_user.id },
      success_url: success_payments_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: cancel_payments_url
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  # GET /payments/success
  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    subscription = Stripe::Subscription.retrieve(session.subscription)

    current_user.update!(
      stripe_subscription_id: subscription.id,
      billing_status: subscription.status,
      plan_name: plan_name_for(current_user),
      subscription_ends_at: Time.at(subscription.current_period_end),
      pending_payment: false
    )

    redirect_to profile_path, notice: "Subscription active!"
  end

  # GET /payments/cancel
  def cancel
    redirect_to profile_path, alert: "Checkout cancelled."
  end

  # POST /payments/portal
  def portal
    if current_user.stripe_customer_id.blank?
      return redirect_to(edit_payments_path, alert: "No billing profile found yet. Start a subscription first.")
    end

    portal_session = Stripe::BillingPortal::Session.create(
      customer: current_user.stripe_customer_id,
      return_url: edit_payments_url
    )

    redirect_to portal_session.url, allow_other_host: true, status: :see_other
  end

  private

  def authorize_user!
    redirect_to(root_path, alert: "Access denied.") unless current_user.teacher? || current_user.family?
  end

  def price_id_for(user)
    if user.teacher?
      Rails.application.credentials.dig(:stripe, :teacher_price_id)
    else
      Rails.application.credentials.dig(:stripe, :family_price_id)
    end
  end

  def plan_name_for(user)
    user.teacher? ? "Teacher Plan" : "Family Plan"
  end
end
