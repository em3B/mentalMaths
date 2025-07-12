class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_classroom

  def index
    @students = @classroom.students
  end

  def new
    @student = User.new
  end

  def create
    @student = User.new(student_params)
    @student.role = "student"
    generated_password = Devise.friendly_token.first(8)
    @student.password = generated_password
    if @student.save
      @student.update(classroom: @classroom)
      redirect_to classroom_path(@classroom), notice: "Student added with password: #{generated_password}"
    else
      @students = @classroom.students
      @new_student = @student
      render "classrooms/show", status: :unprocessable_entity
    end
  end

  def destroy
    @classroom = Classroom.find(params[:classroom_id])
    @student = @classroom.students.find(params[:id])
    @student.update(classroom: nil)  # Remove student from classroom but don’t delete user

    respond_to do |format|
      format.turbo_stream if turbo_frame_request?
      format.html { redirect_to classroom_path(@classroom), notice: "Student removed." }
    end
  end

  private

  def set_classroom
    @classroom = current_user.classrooms.find(params[:classroom_id])
  end

  def student_params
    params.require(:user).permit(:username, :email)
  end
end
