class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")

    event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)

    case event.type
    when "checkout.session.completed"
      handle_checkout_session_completed(event.data.object)

    when "customer.subscription.created",
         "customer.subscription.updated",
         "customer.subscription.deleted"
      handle_subscription(event.data.object)
    end

    head :ok
  rescue JSON::ParserError
    head :bad_request
  rescue Stripe::SignatureVerificationError
    head :bad_request
  end

  private

  def handle_checkout_session_completed(session)
    # Only care about subscription mode checkouts (the school plan)
    return unless session.mode == "subscription"

    school_id = session.metadata&.[]("school_id")
    user_id   = session.metadata&.[]("initiated_by_user_id")

    return if school_id.blank? || user_id.blank?

    school = School.find_by(id: school_id)
    user   = User.find_by(id: user_id)

    return if school.nil? || user.nil?

    # Ensure the school has the customer id (idempotent)
    if school.stripe_customer_id.blank? && session.customer.present?
      school.update!(stripe_customer_id: session.customer)
    end

    # Bootstrap: first successful checkout -> mark initiator as school admin
    user.update!(school_id: school.id, school_admin: true) unless user.school_admin?
  end

  def handle_subscription(subscription)
    customer_id = subscription.customer
    period_end = Time.at(subscription.current_period_end)

    seat_quantity = subscription.items.data.sum { |item| item.quantity.to_i }

    if (user = User.find_by(stripe_customer_id: customer_id))
      user.update!(
        stripe_subscription_id: subscription.id,
        billing_status: subscription.status,
        subscription_ends_at: period_end,
        pending_payment: false
      )
    elsif (school = School.find_by(stripe_customer_id: customer_id))
      school.update!(
        stripe_subscription_id: subscription.id,
        billing_status: subscription.status,
        subscription_ends_at: period_end,
        seat_limit: seat_quantity
      )
    end
  end
end
