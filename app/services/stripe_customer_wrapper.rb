class StripeCustomerWrapper
  def self.retrieve(customer_id)
    Stripe::Customer.retrieve(customer_id)
  end

  def self.create(attributes)
    Stripe::Customer.create(attributes)
  end
end
