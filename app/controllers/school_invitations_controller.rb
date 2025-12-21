class SchoolInvitationsController < ApplicationController
  before_action :set_invitation

  def show
    if @invitation.accepted?
      return redirect_to root_path, alert: "That invitation has already been used."
    end

    if @invitation.expired?
      return redirect_to root_path, alert: "That invitation has expired."
    end

    # If not logged in, store token and send to login/signup
    unless user_signed_in?
      session[:pending_school_invite_token] = @invitation.token
      redirect_to new_user_session_path, alert: "Please sign in to accept the invitation."
    end

    # If logged in, show accept page (or accept immediately if you prefer)
  end

  def accept
    unless user_signed_in?
      session[:pending_school_invite_token] = @invitation.token
      return redirect_to new_user_session_path, alert: "Please sign in to accept the invitation."
    end

    school = @invitation.school

    unless school.active_subscription?
      return redirect_to root_path, alert: "This school's subscription is not active."
    end

    unless school.seats_available?
      return redirect_to root_path, alert: "This school has no available seats."
    end

    unless current_user.teacher?
      return redirect_to root_path, alert: "Only teacher accounts can join a school plan."
    end

    current_user.update!(school: school)
    @invitation.update!(accepted_at: Time.current)

    redirect_to teacher_dashboard_path, notice: "You’ve joined #{school.name}."
  end

  private

  def set_invitation
    @invitation = SchoolInvitation.find_by!(token: params[:token])
  end
end
