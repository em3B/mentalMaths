class TopicsController < ApplicationController
  def index
    if params[:category].present?
      @category = Topic::CATEGORIES.find { |cat| cat.parameterize == params[:category] }
      @topics = Topic.where(category: @category) if @category
    else
      @categories = Topic.distinct.pluck(:category)
    end
  end

  def show
    @topic = Topic.find(params[:id])
  end

  def play
    @topic = Topic.find(params[:id])

    # You can also configure a time limit for certain activities here
    time_limit = params[:time_limit].present? ? params[:time_limit].to_i : nil

    session[:score] = 0 # Reset score

    if time_limit
      session[:time_limit] = time_limit # Store time limit for the session
    end
  end

  def intro
    @topic = Topic.find(params[:id])
  end

  def score
    @topic = Topic.find(params[:id])
    @scores = @topic.scores
      .where(user: current_user)
      .order(created_at: :desc)
      .page(params[:page])
      .per(10)
  end

  def submit_score
    @topic = Topic.find(params[:id])

    # Assume params[:score] contains the user's final score from the quiz form
    final_score = params[:score].to_i

    # Save the score record for current_user and this topic
    @topic.scores.create(user: current_user, value: final_score)

    redirect_to score_topic_path(@topic), notice: "Your score has been saved!"
  end
end
