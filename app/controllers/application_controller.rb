class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :user_signed_in, :current_user

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

  protected

  def configure_permitted_parameters
    keys = [ :login, :role, :username ]
    devise_parameter_sanitizer.permit(:sign_in, keys: keys)
    devise_parameter_sanitizer.permit(:sign_up,  keys: [ :email, :username, :password, :password_confirmation, :role, :first_name, :last_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :email, :username, :password, :password_confirmation, :current_password, :role ])
  end
end
