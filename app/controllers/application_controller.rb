class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :user_signed_in, :current_user

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :role ])
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :role ])

    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :role, :username ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :role, :username ])
  end

  def after_sign_in_path_for(resource)
    Rails.logger.debug "ROLE IS: #{resource.role.inspect}"
    case resource.role
    when "teacher"
      teacher_dashboard_path
    when "family"
      family_dashboard_path
    when "student"
      topics_path
    else
      root_path
    end
  end
end
