class ClassroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_teacher

  def index
    @classrooms = current_user.classrooms
  end

  def show
    @classroom = current_user.classrooms.find(params[:id])
    @students = @classroom.students
    @new_student = User.new(role: "student", classroom: @classroom)
    @assignments = @classroom.assigned_topics.includes(:topic)
  end

  def new
    @classroom = current_user.classrooms.new
  end

  def create
    @classroom = current_user.classrooms.new(classroom_params)
    if @classroom.save
      redirect_to @classroom, notice: "Classroom created"
    else
      render :new
    end
  end

  def scores
    @classroom = current_user.classrooms.find(params[:id])
    @students = @classroom.students.includes(:scores)
  end

  def destroy
    @classroom = current_user.classrooms.find(params[:id])
    @classroom.destroy
    redirect_to classrooms_path, notice: "Classroom deleted"
  end

  private

  def classroom_params
    params.require(:classroom).permit(:name)
  end

  def require_teacher
    redirect_to root_path unless current_user.teacher?
  end
end
