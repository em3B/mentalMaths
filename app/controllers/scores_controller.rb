class ScoresController < ApplicationController
  before_action :authenticate_user!  # this ensures only signed-in users can access

  def index
    @scores = current_user.scores.includes(:topic).order(created_at: :desc).group_by(&:topic)
  end

  def create
    @score = current_user.scores.build(
      correct: params[:score][:correct],
      total: params[:score][:total]
    )

    if @score.save
      render json: { message: "Score updated!" }, status: :created
    else
      render json: { errors: @score.errors.full_message }, status: :unprocessable_entity
    end
  end
end
