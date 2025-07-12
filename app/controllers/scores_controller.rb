class ScoresController < ApplicationController
  before_action :authenticate_user!

def index
  if current_user.student?
    # Students see their own scores
    @scores = current_user.scores.includes(:topic).order(created_at: :desc).page(params[:page])

  elsif current_user.family?
    # Families must pass a child_id param
    if params[:child_id].present?
      @child = current_user.children.find_by(id: params[:child_id])

      if @child
        @scores = @child.scores.includes(:topic).order(created_at: :desc).page(params[:page])
      else
        redirect_to family_dashboard_path, alert: "Child not found or not authorized."
      end
    else
      redirect_to family_dashboard_path, alert: "Please select a child to view scores."
    end

  elsif current_user.teacher?
    # Teachers must pass a student_id param
    if params[:student_id].present?
      # Only allow students enrolled in the teacher's classrooms
      student = User.find_by(id: params[:student_id])

      if student&.student? && (student.enrolled_classrooms & current_user.classrooms).any?
        @scores = student.scores.includes(:topic).order(created_at: :desc).page(params[:page])
      else
        redirect_to teacher_dashboard_path, alert: "Student not found or not authorized."
      end
    else
      redirect_to teacher_dashboard_path, alert: "Please select a student to view scores."
    end

  else
    redirect_to root_path, alert: "You are not authorized to view scores."
  end
end

def show
  @student = User.find(params[:id])
  @scores = @student.scores.order(created_at: :desc).page(params[:page])
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
