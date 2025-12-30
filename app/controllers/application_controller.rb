class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :user_signed_in, :current_user
  after_action :consume_school_invite_token, if: :user_signed_in?

  def after_sign_in_path_for(resource)
    # If user clicked "School subscriptions" start flow,
    # send them straight back into school onboarding after login.
    if session[:school_onboarding]
      return new_school_path
    end

    Rails.logger.debug "ROLE IS: #{resource.role.inspect}"
    case resource.role
    when "teacher"
      # School admins should land on Members; regular teachers land on Classrooms/Dashboard
      if resource.school_admin? && resource.school.present?
        members_school_path(resource.school)
      else
        teacher_dashboard_path
      end
    when "family"
      family_dashboard_path
    when "student"
      topics_path
    else
      root_path
    end
  end

  def after_sign_up_path_for(resource)
    # Same idea as after_sign_in_path_for: if they signed up as part of
    # school onboarding, continue that flow.
    if session[:school_onboarding]
      return new_school_path
    end

    # fall back to Devise default (or you could mirror your role logic here)
    super
  end

  protected

  def configure_permitted_parameters
    keys = [ :login, :role, :username ]

    devise_parameter_sanitizer.permit(:sign_in, keys: keys)
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [ :email, :username, :password, :password_confirmation, :role, :first_name, :last_name ]
    )
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [ :email, :username, :password, :password_confirmation, :current_password, :role ]
    )
  end

  private

  def consume_school_invite_token
    token = session.delete(:pending_school_invite_token)
    return if token.blank?

    invitation = SchoolInvitation.find_by(token: token)
    return if invitation.nil? || invitation.accepted? || invitation.expired?

    # redirect isn't possible safely in after_action, so just store and show banner
    # Better approach: do this in a custom SessionsController or a dedicated endpoint.
    session[:post_login_invite_token] = token
  end
end
