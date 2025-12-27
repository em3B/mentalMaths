class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def teacher
    redirect_to root_path unless current_user.teacher?
    @classrooms = current_user.classrooms
    @new_classroom = Classroom.new
    @new_student = User.new
  end

  def family
    redirect_to root_path unless current_user.family?
    @children = current_user.children
    @child    = User.new
    @assignments_by_child = @children.each_with_object({}) do |child, h|
      h[child] = child.assigned_topics.includes(:topic)
    end
  end

  def create_child
    return redirect_to(root_path) unless current_user.family?

    @child = User.new(child_params)
    @child.role = "student"
    @child.created_by_family = true
    @child.parent_id = current_user.id

    @child.email = "#{SecureRandom.hex(6)}@child.local" if @child.email.blank?

    if @child.save
      redirect_to family_dashboard_path, notice: "Child created successfully."
    else
      @children = current_user.children
      @assignments_by_child = @children.each_with_object({}) do |child, h|
        h[child] = child.assigned_topics.includes(:topic)
      end
      render :family, status: :unprocessable_entity
    end
  end

  def create_classroom
    return redirect_to(root_path) unless current_user.teacher?

    @new_classroom = current_user.classrooms.new(classroom_params)

    if @new_classroom.save
      redirect_to teacher_dashboard_path, notice: "Classroom created successfully."
    else
      @classrooms  = current_user.classrooms.reload
      @new_student = User.new
      render :teacher, status: :unprocessable_entity
    end
  end

  def create_student
    return redirect_to(root_path) unless current_user.teacher?

    # ✅ authorize classroom first (prevents creating a student if classroom isn't yours)
    classroom = current_user.classrooms.find(params[:classroom_id])

    @new_student = User.new(student_params)
    @new_student.role              = "student"
    @new_student.created_by_family = false
    @new_student.classroom         = classroom

    if @new_student.save
      # Only if your app actually has this join model
      Membership.create!(user: @new_student, classroom: classroom) if defined?(Membership)

      redirect_to teacher_dashboard_path, notice: "Student added successfully."
    else
      @classrooms    = current_user.classrooms
      @new_classroom = current_user.classrooms.new
      render :teacher, status: :unprocessable_entity
    end
  end

  private

  def child_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end

  def classroom_params
    params.require(:classroom).permit(:name)
  end

  def student_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end
end
