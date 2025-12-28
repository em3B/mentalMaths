class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)

    # If they came from a school invite, force role = teacher
    token = session[:pending_school_invite_token]
    if token.present?
      resource.role = "teacher"
    end

    resource.save
    yield resource if block_given?

    if resource.persisted?
      sign_in(resource)

      # If they have an invite token, accept it (seat checks happen there)
      if token.present?
        invitation = SchoolInvitation.find_by(token: token)

        if invitation && !invitation.accepted? && !invitation.expired?
          school = invitation.school

          if school.active_subscription? && school.seats_available?
            resource.update!(school: school)
            invitation.update!(accepted_at: Time.current)
            session.delete(:pending_school_invite_token)

            return redirect_to teacher_dashboard_path, notice: "You’ve joined #{school.name}."
          end
        end

        # If something failed, keep token and send them back to invite page to see message
        return redirect_to school_invitation_path(token), alert: "Invite could not be accepted. Please contact your school admin."
      end

      # Normal flow for non-invite users
      if session.delete(:school_onboarding)
        # they came from the school subscriptions button
        return redirect_to new_school_path
      end

      redirect_to edit_payments_path
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end
end
