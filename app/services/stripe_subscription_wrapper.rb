class StripeSubscriptionWrapper
  def self.create(attributes)
    Stripe::Subscription.create(attributes)
  end
end
