class AssignedTopicsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_classroom, only: [ :create_for_class ]
  before_action :set_student_and_classroom, only: [ :create_for_user ]

  def create_for_class
  classroom = current_user.classrooms.find(params[:classroom_id])
    AssignedTopic.create!(
      classroom: classroom,
      topic_id: params[:topic_id],
      assigned_by: current_user,
      due_date: params[:due_date]
    )
    redirect_back fallback_location: teacher_dashboard_path, notice: "Assigned!"
  end

  def create_for_user
    authorize_assignment(@classroom, @student)

    AssignedTopic.create!(
      user: @student,
      topic_id: params[:topic_id],
      assigned_by: current_user,
      due_date: params[:due_date]
    )

    redirect_back fallback_location: teacher_dashboard_path, notice: "Assigned to #{@student.username}!"
  end

  def destroy_for_class
    classroom = current_user.classrooms.find(params[:id] = params[:classroom_id])
    assignment = AssignedTopic.find(params[:id])

    if assignment.classroom_id == classroom.id
      assignment.destroy
      redirect_to classroom_path(classroom), notice: "Assignment removed."
    else
      head :forbidden
    end
  end

  private

  def set_classroom
    @classroom = current_user.classrooms.find(params[:id] || params[:classroom_id])
  end

  def set_student_and_classroom
    @student   = User.find(params[:id] || params[:student_id])
    @classroom = @student.classroom
  end

  def authorize_assignment(classroom, student = nil)
    if current_user.teacher?
      redirect_to(root_path, alert: "Unauthorized") unless classroom.teacher == current_user
    elsif current_user.family?
      redirect_to(root_path, alert: "Unauthorized") unless student&.parent == current_user
    else
      redirect_to(root_path, alert: "Unauthorized")
    end
  end
end
