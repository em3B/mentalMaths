class SchoolCheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_school
  before_action :require_school_admin!

  def create
    seats = params[:seats].to_i
    seats = 1 if seats < 1

    customer = if @school.stripe_customer_id.present?
                 StripeCustomerWrapper.retrieve(@school.stripe_customer_id)
    else
                 StripeCustomerWrapper.create(email: @school.contact_email, name: @school.name)
    end

    @school.update!(stripe_customer_id: customer.id)

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      metadata: {
        school_id: @school.id,
        initiated_by_user_id: current_user.id
      },
      customer: customer.id,
      line_items: [ {
        price: Rails.application.credentials.dig(:stripe, :school_price_id),
        quantity: seats
      } ],
      success_url: schools_checkout_success_url + "?school_id=#{@school.id}",
      cancel_url: schools_checkout_cancel_url
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    redirect_to school_path(@school), notice: "School subscription started."
  end

  def cancel
    redirect_to school_path(@school), alert: "Checkout cancelled."
  end

  private

  def set_school
    @school = School.find(params[:id] || params[:school_id])
  end

  def require_school_admin!
    return redirect_to(root_path, alert: "Access denied.") unless current_user.school_id == @school.id

    has_admin = User.exists?(school_id: @school.id, school_admin: true)

    return if current_user.school_admin?
    return if !has_admin && current_user.teacher? # bootstrap

    redirect_to root_path, alert: "Access denied."
  end
end
