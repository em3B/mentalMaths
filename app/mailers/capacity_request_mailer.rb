class CapacityRequestMailer < ApplicationMailer
  default from: "no-reply@mentalmathsapp.com"

  def new_request_notification(capacity_request)
    @capacity_request = capacity_request

    mail(
      to: recipient_email,
      subject: "New Capacity Request (#{capacity_request.request_type_name.titleize}) from #{capacity_request.user.name || capacity_request.user.email}"
    )
  end

  private

  def recipient_email
    case Rails.env
    when "development", "test"
      ENV.fetch("CAPACITY_REQUESTS_EMAIL_DEV", "dev@example.com")
    else
      ENV.fetch("CAPACITY_REQUESTS_EMAIL", "admin@mentalmathsapp.com")
    end
  end
end
