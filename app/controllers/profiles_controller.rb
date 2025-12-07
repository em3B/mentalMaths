class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def authorize_user!
    unless current_user.teacher? || current_user.family?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
