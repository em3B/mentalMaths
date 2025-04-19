class QuestionsController < ApplicationController
  before_action :set_topic, only: [ :show, :answer ]
  before_action :check_authentication_required, only: [ :show, :answer ]

  def show
    @question = @topic.questions.order("RANDOM()").first
  end

  def answer
    @question = @topic.questions.find(params[:id])
    user_answer = params[:value].to_i

    # Save response only if user is signed in
    if user_signed_in?
      Response.create!(
        question: @question,
        value: user_answer,
        user_id: current_user.id
      )
    end

    # Track score for everyone (signed in or guest)
    session[:score] ||= 0
    session[:score] += 1 if user_answer == @question.correct_answer

    # Redirect or render as needed
    # redirect_to next_question_path
  end

  def score
    @score = session[:score]

    # Clear only guest data (keep signed-in user's responses)
    unless user_signed_in?
      session.delete(:score)
    end

    session.delete(:questions)
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
