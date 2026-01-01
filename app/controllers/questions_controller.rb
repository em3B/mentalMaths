class QuestionsController < ApplicationController
  before_action :set_topic, only: [ :show, :answer ]
  before_action :check_authentication_required, only: [ :show, :answer ]

  def show
    @question = @topic.questions.order("RANDOM()").first
  end

  def answer
    @question = @topic.questions.find(params[:id])
    user_answer = params[:value].to_i
    render json: { correct: (user_answer == @question.correct_answer) }
  end

  private

  def set_topic
    @topic = Topic.find(params[:topic_id])
  end

  def check_authentication_required
    if @topic.requires_auth && !user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in to access this topic."
    end
  end
end
