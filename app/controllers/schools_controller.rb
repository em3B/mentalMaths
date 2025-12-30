class SchoolsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :billing, :members, :invite_teacher ]
  before_action :set_school, only: [ :billing, :members, :invite_teacher ]
  before_action :require_school_admin!, only: [ :billing, :members, :invite_teacher ]

  def new
    session.delete(:school_onboarding)
    @school = School.new
  end

  def start
    session[:school_onboarding] = true
    redirect_to(user_signed_in? ? new_school_path : new_user_registration_path)
  end

  def create
    @school = School.new(school_params)
    if @school.save
      current_user.update!(school: @school, school_admin: true)
      redirect_to billing_school_path(@school)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def billing
    # @school set by set_school
  end

  def members
    # @school set by set_school
  end

  def invite_teacher
    email = params[:email].to_s.downcase.strip
    @invitation = @school.school_invitations.create!(
      email: email,
      expires_at: 14.days.from_now
    )
    render :members
  end

  private

  def school_params
    params.require(:school).permit(:name, :address, :contact_email)
  end

  def set_school
    @school = School.find(params[:id])
  end

  def require_school_admin!
    unless current_user.school_admin? && current_user.school_id == @school.id
      redirect_to root_path, alert: "Access denied."
    end
  end
end
