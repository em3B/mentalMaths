require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  WEBHOOK_PATH = "/stripe/webhook"

  setup do
    @original_secret = ENV["STRIPE_WEBHOOK_SECRET"]
    ENV["STRIPE_WEBHOOK_SECRET"] = "whsec_test_123"

    @school = School.create!(
      name: "Webhook School",
      address: "1 Webhook Street",
      contact_email: "billing@webhook-school.example",
      stripe_customer_id: nil
    )

    @user = User.create!(
      email: "teacher-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      username: "teacher_#{SecureRandom.hex(4)}",
      role: "teacher",
      school: nil,
      school_admin: false,
      stripe_customer_id: nil
    )
  end

  teardown do
    ENV["STRIPE_WEBHOOK_SECRET"] = @original_secret
  end

  # ---- checkout.session.completed ------------------------------------------

  test "checkout.session.completed bootstraps school customer id and sets initiating user as school admin" do
    event_hash = {
      id: "evt_checkout_1",
      type: "checkout.session.completed",
      data: {
        object: {
          id: "cs_test_1",
          mode: "subscription",
          customer: "cus_school_123",
          metadata: {
            "school_id" => @school.id.to_s,
            "initiated_by_user_id" => @user.id.to_s
          }
        }
      }
    }

    with_stripe_construct_event(event_hash) do
      post_webhook(event_hash.to_json)
    end

    assert_response :ok

    @school.reload
    assert_equal "cus_school_123", @school.stripe_customer_id

    @user.reload
    assert_equal @school.id, @user.school_id
    assert_equal true, @user.school_admin
  end

  test "checkout.session.completed is idempotent for stripe_customer_id and does not unset admin" do
    # pre-set school customer and mark user already admin
    @school.update!(stripe_customer_id: "cus_existing")
    @user.update!(school: @school, school_admin: true)

    event_hash = {
      id: "evt_checkout_2",
      type: "checkout.session.completed",
      data: {
        object: {
          id: "cs_test_2",
          mode: "subscription",
          customer: "cus_new_should_not_override",
          metadata: {
            "school_id" => @school.id.to_s,
            "initiated_by_user_id" => @user.id.to_s
          }
        }
      }
    }

    with_stripe_construct_event(event_hash) do
      post_webhook(event_hash.to_json)
    end

    assert_response :ok

    @school.reload
    assert_equal "cus_existing", @school.stripe_customer_id

    @user.reload
    assert_equal true, @user.school_admin
  end

  test "checkout.session.completed does nothing when mode is not subscription" do
    event_hash = {
      id: "evt_checkout_3",
      type: "checkout.session.completed",
      data: {
        object: {
          id: "cs_test_3",
          mode: "payment",
          customer: "cus_ignore",
          metadata: {
            "school_id" => @school.id.to_s,
            "initiated_by_user_id" => @user.id.to_s
          }
        }
      }
    }

    with_stripe_construct_event(event_hash) do
      post_webhook(event_hash.to_json)
    end

    assert_response :ok

    @school.reload
    assert_nil @school.stripe_customer_id

    @user.reload
    assert_equal false, @user.school_admin
    assert_nil @user.school_id
  end

  test "checkout.session.completed does nothing when metadata is missing" do
    event_hash = {
      id: "evt_checkout_4",
      type: "checkout.session.completed",
      data: {
        object: {
          id: "cs_test_4",
          mode: "subscription",
          customer: "cus_ignore",
          metadata: {}
        }
      }
    }

    with_stripe_construct_event(event_hash) do
      post_webhook(event_hash.to_json)
    end

    assert_response :ok

    @school.reload
    assert_nil @school.stripe_customer_id

    @user.reload
    assert_equal false, @user.school_admin
  end

  # ---- subscription events --------------------------------------------------

  test "subscription.updated updates user subscription fields when customer matches user stripe_customer_id" do
    @user.update!(stripe_customer_id: "cus_user_1", pending_payment: true)

    event_hash = {
      id: "evt_sub_user_1",
      type: "customer.subscription.updated",
      data: {
        object: {
          id: "sub_user_1",
          customer: "cus_user_1",
          status: "active",
          current_period_end: Time.now.to_i + 30.days.to_i,
          items: { data: [ { quantity: 1 } ] }
        }
      }
    }

    with_stripe_construct_event(event_hash) do
      post_webhook(event_hash.to_json)
    end

    assert_response :ok

    @user.reload
    assert_equal "sub_user_1", @user.stripe_subscription_id
    assert_equal "active", @user.billing_status
    assert @user.subscription_ends_at.present?
    assert_equal false, @user.pending_payment
  end

  test "subscription.updated updates school subscription fields when customer matches school stripe_customer_id and sets seat_limit from quantities" do
    @school.update!(stripe_customer_id: "cus_school_1")

    event_hash = {
      id: "evt_sub_school_1",
      type: "customer.subscription.updated",
      data: {
        object: {
          id: "sub_school_1",
          customer: "cus_school_1",
          status: "active",
          current_period_end: Time.now.to_i + 30.days.to_i,
          items: { data: [ { quantity: 3 }, { quantity: 2 } ] }
        }
      }
    }

    with_stripe_construct_event(event_hash) do
      post_webhook(event_hash.to_json)
    end

    assert_response :ok

    @school.reload
    assert_equal "sub_school_1", @school.stripe_subscription_id
    assert_equal "active", @school.billing_status
    assert @school.subscription_ends_at.present?
    assert_equal 5, @school.seat_limit
  end

  test "subscription events do nothing when customer id matches neither user nor school" do
    event_hash = {
      id: "evt_sub_none",
      type: "customer.subscription.updated",
      data: {
        object: {
          id: "sub_none",
          customer: "cus_unknown",
          status: "active",
          current_period_end: Time.now.to_i + 30.days.to_i,
          items: { data: [ { quantity: 9 } ] }
        }
      }
    }

    with_stripe_construct_event(event_hash) do
      post_webhook(event_hash.to_json)
    end

    assert_response :ok
  end

  # ---- error handling -------------------------------------------------------

  test "returns bad_request when Stripe signature verification fails" do
    # Force construct_event to raise signature error
    with_stripe_construct_event_raising(Stripe::SignatureVerificationError.new("bad", "sig")) do
      post_webhook({ hello: "world" }.to_json)
    end

    assert_response :bad_request
  end

  test "returns bad_request when JSON is invalid" do
    # Invalid JSON triggers JSON::ParserError before Stripe verification in your rescue chain
    # (depending on Stripe internals, but this is safe: our stub will raise JSON::ParserError)
    with_stripe_construct_event_raising(JSON::ParserError.new("bad json")) do
      post_webhook("not-json")
    end

    assert_response :bad_request
  end

  private

  def post_webhook(body)
    post WEBHOOK_PATH,
         params: body,
         headers: {
           "CONTENT_TYPE" => "application/json",
           "HTTP_STRIPE_SIGNATURE" => "test"
         }
  end

  def with_stripe_construct_event(event_hash)
    original = Stripe::Webhook.method(:construct_event) rescue nil

    Stripe::Webhook.define_singleton_method(:construct_event) do |*_args|
      Stripe::Event.construct_from(event_hash)
    end

    yield
  ensure
    restore_construct_event(original)
  end

  def with_stripe_construct_event_raising(error)
    original = Stripe::Webhook.method(:construct_event) rescue nil

    Stripe::Webhook.define_singleton_method(:construct_event) do |*_args|
      raise error
    end

    yield
  ensure
    restore_construct_event(original)
  end

  def restore_construct_event(original)
    if original
      Stripe::Webhook.define_singleton_method(:construct_event, original)
    else
      class << Stripe::Webhook
        remove_method :construct_event
      end
    end
  end
end
