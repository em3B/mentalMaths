class ScoresController < ApplicationController
  before_action :authenticate_user!  # this ensures only signed-in users can access

  def index
    @scores = current_user.scores.includes(:topic).order(created_at: :desc).group_by(&:topic)
  end
end
