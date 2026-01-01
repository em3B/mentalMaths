class ScoresController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.student?
      @scores = current_user.scores
      .includes(:topic)
      .order(created_at: :desc)
      .page(params[:page])
      .per(10)

    elsif current_user.family?
      if params[:child_id].present?
        @student = current_user.children.find_by(id: params[:child_id])

        if @student
          @scores = @student.scores.includes(:topic).order(created_at: :desc).page(params[:page])
        else
          redirect_to family_dashboard_path, alert: "Child not found or not authorized."
        end
      else
        redirect_to family_dashboard_path, alert: "Please select a child to view scores."
      end

    elsif current_user.teacher?
      if params[:student_id].present?
        @student = authorized_teacher_student(params[:student_id])

        if @student
          @scores = @student.scores.includes(:topic).order(created_at: :desc).page(params[:page])
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

  # GET /students/:id/scores
  def show
    if current_user.student?
      @student = current_user

    elsif current_user.family?
      @student = current_user.children.find_by(id: params[:id])
      return redirect_to family_dashboard_path, alert: "Student not found or not authorized." unless @student

    elsif current_user.teacher?
      @student = authorized_teacher_student(params[:id])
      return redirect_to teacher_dashboard_path, alert: "Student not found or not authorized." unless @student

    else
      return redirect_to root_path, alert: "You are not authorized to view scores."
    end

    @scores = @student.scores.includes(:topic).order(created_at: :desc).page(params[:page])
  end

  # POST /scores (from JS)
  def create
    score_params = params.require(:score).permit(:correct, :total, :topic_id)

    topic = Topic.find(score_params[:topic_id])

    @score = current_user.scores.build(
      correct: score_params[:correct],
      total: score_params[:total],
      topic: topic
    )

    if @score.save
      render json: { message: "Score saved!" }, status: :created
    else
      render json: { errors: @score.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authorized_teacher_student(id)
    student = User.find_by(id: id)
    return nil unless student&.student?

    (student.enrolled_classrooms & current_user.classrooms).any? ? student : nil
  end
end
