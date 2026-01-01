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

  def intro
    @topic = Topic.find(params[:id])
  end

  def play
    @topic = Topic.find(params[:id])

    if @topic.requires_auth && !user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in to access this topic."
      return
    end

    # Optional: pass a time limit to the frontend
    @time_limit = params[:time_limit].present? ? params[:time_limit].to_i : nil
  end

  def score
    @topic = Topic.find(params[:id])

    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Please sign in to view your scores."
      return
    end

    @scores = @topic.scores
      .where(user: current_user)
      .order(created_at: :desc)
      .page(params[:page])
      .per(10)
  end
end
