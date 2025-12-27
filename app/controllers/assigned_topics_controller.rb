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
    return unless authorize_assignment(@classroom, @student)

    AssignedTopic.create!(
      user: @student,
      topic_id: params[:topic_id],
      assigned_by: current_user,
      due_date: params[:due_date]
    )

    redirect_back fallback_location: teacher_dashboard_path, notice: "Assigned to #{@student.username}!"
  end

def destroy_for_class
  classroom = current_user.classrooms.find(params[:classroom_id])
  assignment = AssignedTopic.find(params[:id])

  if assignment.classroom_id == classroom.id
    assignment.destroy
    redirect_to classroom_path(classroom), notice: "Assignment removed."
  else
    head :forbidden
  end
end

def destroy_for_user
  user = current_user.children.find(params[:user_id])
  assignment = AssignedTopic.find(params[:id])

  if assignment.user_id == user.id
    assignment.destroy
    redirect_to family_dashboard_path, notice: "Assignment removed."
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
      unless classroom.teacher == current_user
        redirect_to(root_path, alert: "Unauthorized") and return false
      end
    elsif current_user.family?
      unless student&.parent == current_user
        redirect_to(root_path, alert: "Unauthorized") and return false
      end
    else
      redirect_to(root_path, alert: "Unauthorized") and return false
    end

    true
  end
end
