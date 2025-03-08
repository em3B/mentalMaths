class TopicsController < ApplicationController
  def index
    @topics = Topic.all
  end

  def show
    @topic = Topic.find(params[:id])
  end

  def play
    @topic = Topic.find(params[:id])
    
    # Default question limit to 20 if no limit is provided
    limit = params[:limit].present? ? params[:limit].to_i : 20

    # You can also configure a time limit for certain activities here
    time_limit = params[:time_limit].present? ? params[:time_limit].to_i : nil

    # Randomize questions and set a limit
    session[:questions] = @topic.questions.order("RANDOM()").limit(limit).pluck(:id)
    session[:score] = 0 # Reset score

    if time_limit
      session[:time_limit] = time_limit # Store time limit for the session
    end

    redirect_to question_path(session[:questions].first) # Start quiz
  end
end
