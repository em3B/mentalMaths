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
    @student.role = :student
    @student.password = Devise.friendly_token.first(8) # auto-generate a password
    if @student.save
      Membership.create(user: @student, classroom: @classroom)
      redirect_to classroom_students_path(@classroom), notice: "Student added"
    else
      render :new
    end
  end

  private

  def set_classroom
    @classroom = current_user.classrooms.find(params[:classroom_id])
  end

  def student_params
    params.require(:user).permit(:name, :email)
  end
end
