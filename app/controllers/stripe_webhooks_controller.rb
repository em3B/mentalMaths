class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")

    event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)

    case event.type
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

  def handle_subscription(subscription)
    customer_id = subscription.customer
    period_end = Time.at(subscription.current_period_end)

    # Seats: for school plans quantity matters (for individual it can be ignored)
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
