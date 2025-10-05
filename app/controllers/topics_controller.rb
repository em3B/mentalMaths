class TopicsController < ApplicationController
  def index
    if params[:category].present?
      category_param = params[:category].tr("-", " ")
      @category = category_param.titleize
      @topics = Topic.where("LOWER(category) = ?", category_param.downcase)
    else
      @topics = Topic.all
      @categories = Topic.distinct.pluck(:category)
    end
    if current_user != nil && current_user&.role&.downcase == "student"
      @assignments = current_user.assigned_topics.includes(:topic)
    end
  end

  def show
    @topic = Topic.find(params[:id])
    if current_user != nil && current_user.teacher?
      @classrooms = current_user.classrooms
      if params[:classroom_id].present?
      @selected_classroom = @classrooms.find_by(id: params[:classroom_id])
      else
        @selected_classroom = @classrooms.first
      end
    elsif current_user != nil && current_user.role.downcase == "family"
      @students = current_user.children
      @selected_student = @students.find_by(id: params[:student_id]) || @students.first
    end
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
