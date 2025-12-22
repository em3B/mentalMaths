require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  test "create accepts a webhook payload" do
    payload_hash = {
      id: "evt_test_123",
      type: "customer.subscription.updated",
      data: {
        object: {
          id: "sub_test_123",
          customer: "cus_test_123",
          status: "active",
          current_period_end: Time.now.to_i,
          items: { data: [ { quantity: 5 } ] }
        }
      }
    }

    payload = payload_hash.to_json
    fake_event = Stripe::Event.construct_from(payload_hash)

    original_construct_event = Stripe::Webhook.method(:construct_event) rescue nil
    Stripe::Webhook.define_singleton_method(:construct_event) { |*_args| fake_event }

    original_secret = ENV["STRIPE_WEBHOOK_SECRET"]
    ENV["STRIPE_WEBHOOK_SECRET"] = "whsec_test_123"

    post "/stripe/webhook",
         params: payload,
         headers: {
           "CONTENT_TYPE" => "application/json",
           "HTTP_STRIPE_SIGNATURE" => "test"
         }

    assert_response :ok
  ensure
    ENV["STRIPE_WEBHOOK_SECRET"] = original_secret

    if original_construct_event
      Stripe::Webhook.define_singleton_method(:construct_event, original_construct_event)
    else
      class << Stripe::Webhook
        remove_method :construct_event
      end
    end
  end
end
