class ScoresController < ApplicationController
  before_action :authenticate_user!

  def index
    @scores = current_user.scores.includes(:topic).order(created_at: :desc).group_by(&:topic)
  end

  def create
    # Safely permit params with strong params
    score_params = params.require(:score).permit(:correct, :total, :topic_id)

    # Find the topic - must exist to associate the score
    topic = Topic.find(score_params[:topic_id])

    @score = current_user.scores.build(
      correct: score_params[:correct],
      total: score_params[:total],
      topic: topic
    )

    if @score.save
      render json: { message: "Score updated!" }, status: :created
    else
      render json: { errors: @score.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
