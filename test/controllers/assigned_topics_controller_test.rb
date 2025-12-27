require "test_helper"

class AssignedTopicsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @teacher = create_user!(role: "teacher")
    @family  = create_user!(role: "family")

    @classroom = create_classroom!(teacher: @teacher)
    @student   = create_student!(username: unique("student"), classroom: @classroom, parent: @family)

    @topic = create_topic!
  end

  # ---- AUTH -----------------------------------------------------------------

  test "requires authentication for create_for_class" do
    post assign_topic_to_class_path_for(@classroom),
         params: { classroom_id: @classroom.id, topic_id: @topic.id }

    assert_redirected_to new_user_session_path
  end

  test "requires authentication for create_for_user" do
    post assign_topic_to_student_path_for(@classroom, @student),
         params: { topic_id: @topic.id }

    assert_redirected_to new_user_session_path
  end

  test "requires authentication for destroy_for_class" do
    assignment = AssignedTopic.create!(classroom: @classroom, topic_id: @topic.id, assigned_by: @teacher)

    delete classroom_assigned_topic_path(@classroom, assignment)

    assert_redirected_to new_user_session_path
  end

  test "requires authentication for destroy_for_user" do
    assignment = AssignedTopic.create!(user: @student, topic_id: @topic.id, assigned_by: @family)

    delete destroy_user_assigned_topic_path(assignment.id, @student.id)

    assert_redirected_to new_user_session_path
  end

  # ---- CREATE FOR CLASS -----------------------------------------------------

  test "teacher can assign topic to their own classroom" do
    sign_in @teacher

    assert_difference("AssignedTopic.count", +1) do
      post assign_topic_to_class_path_for(@classroom),
           params: { classroom_id: @classroom.id, topic_id: @topic.id, due_date: 1.week.from_now.to_date },
           headers: { "HTTP_REFERER" => classroom_path(@classroom) }
    end

    assert_redirected_to classroom_path(@classroom)
    assert_equal "Assigned!", flash[:notice]

    assignment = AssignedTopic.order(:id).last
    assert_equal @classroom.id, assignment.classroom_id
    assert_equal @topic.id, assignment.topic_id
    assert_equal @teacher.id, assignment.assigned_by_id
  end

  test "teacher cannot assign topic to a classroom they do not own (404)" do
    other_teacher   = create_user!(role: "teacher")
    other_classroom = create_classroom!(teacher: other_teacher)

    sign_in @teacher

    assert_no_difference("AssignedTopic.count") do
      post assign_topic_to_class_path_for(other_classroom),
           params: { classroom_id: other_classroom.id, topic_id: @topic.id }
    end

    # current_user.classrooms.find(...) raises RecordNotFound -> 404
    assert_response :not_found
  end

  # ---- CREATE FOR USER ------------------------------------------------------

  test "teacher can assign topic to a student in their classroom" do
    sign_in @teacher

    assert_difference("AssignedTopic.count", +1) do
      post assign_topic_to_student_path_for(@classroom, @student),
           params: { topic_id: @topic.id, due_date: 1.week.from_now.to_date },
           headers: { "HTTP_REFERER" => classroom_path(@classroom) }
    end

    assert_redirected_to classroom_path(@classroom)
    assert_equal "Assigned to #{@student.username}!", flash[:notice]

    assignment = AssignedTopic.order(:id).last
    assert_equal @student.id, assignment.user_id
    assert_equal @topic.id, assignment.topic_id
    assert_equal @teacher.id, assignment.assigned_by_id
  end

  test "teacher cannot assign topic to student outside their classroom (redirects unauthorized)" do
    other_teacher   = create_user!(role: "teacher")
    other_classroom = create_classroom!(teacher: other_teacher)
    other_student   = create_student!(username: unique("student"), classroom: other_classroom, parent: @family)

    sign_in @teacher

    assert_no_difference("AssignedTopic.count") do
      post assign_topic_to_student_path_for(other_classroom, other_student),
           params: { topic_id: @topic.id }
    end

    assert_redirected_to root_path
    assert_equal "Unauthorized", flash[:alert]
  end

  test "family can assign topic to their own child (via nested student route)" do
    sign_in @family

    assert_difference("AssignedTopic.count", +1) do
      post assign_topic_to_student_path_for(@classroom, @student),
           params: { topic_id: @topic.id }
    end

    assert_redirected_to teacher_dashboard_path # fallback (no referer)
    assert_equal "Assigned to #{@student.username}!", flash[:notice]

    assignment = AssignedTopic.order(:id).last
    assert_equal @student.id, assignment.user_id
    assert_equal @topic.id, assignment.topic_id
    assert_equal @family.id, assignment.assigned_by_id
  end

  test "family cannot assign topic to someone else's child (redirects unauthorized)" do
    other_family  = create_user!(role: "family")
    other_student = create_student!(username: unique("student"), classroom: @classroom, parent: other_family)

    sign_in @family

    assert_no_difference("AssignedTopic.count") do
      post assign_topic_to_student_path_for(@classroom, other_student),
           params: { topic_id: @topic.id }
    end

    assert_redirected_to root_path
    assert_equal "Unauthorized", flash[:alert]
  end

  # ---- DESTROY FOR CLASS ----------------------------------------------------

  test "teacher can remove an assignment from their classroom" do
    assignment = AssignedTopic.create!(classroom: @classroom, topic_id: @topic.id, assigned_by: @teacher)

    sign_in @teacher

    assert_difference("AssignedTopic.count", -1) do
      delete classroom_assigned_topic_path(@classroom, assignment)
    end

    assert_redirected_to classroom_path(@classroom)
    assert_equal "Assignment removed.", flash[:notice]
  end

  test "teacher gets forbidden when trying to delete assignment not belonging to classroom" do
    other_teacher   = create_user!(role: "teacher")
    other_classroom = create_classroom!(teacher: other_teacher)
    assignment      = AssignedTopic.create!(classroom: other_classroom, topic_id: @topic.id, assigned_by: other_teacher)

    sign_in @teacher

    assert_no_difference("AssignedTopic.count") do
      delete classroom_assigned_topic_path(@classroom, assignment)
    end

    assert_response :forbidden
  end

  # ---- DESTROY FOR USER -----------------------------------------------------

  test "family can remove an assignment from their child" do
    assignment = AssignedTopic.create!(user: @student, topic_id: @topic.id, assigned_by: @family)

    sign_in @family

    assert_difference("AssignedTopic.count", -1) do
      delete destroy_user_assigned_topic_path(assignment.id, @student.id)
    end

    assert_redirected_to family_dashboard_path
    assert_equal "Assignment removed.", flash[:notice]
  end

  test "family gets forbidden when assignment is not for that child" do
    other_child = create_student!(username: unique("student"), classroom: @classroom, parent: @family)
    assignment  = AssignedTopic.create!(user: other_child, topic_id: @topic.id, assigned_by: @family)

    sign_in @family

    # Try deleting the other child's assignment while passing @student.id in the URL
    assert_no_difference("AssignedTopic.count") do
      delete destroy_user_assigned_topic_path(assignment.id, @student.id)
    end

    assert_response :forbidden
  end

  private

  def assign_topic_to_student_path_for(classroom, student)
    "/classrooms/#{classroom.id}/students/#{student.id}/assign_topic"
  end

  def assign_topic_to_class_path_for(classroom)
    "/classrooms/#{classroom.id}/assign_topic_to_class"
  end

  # ---- creation helpers (adjust fields if your validations require more) -----

  def unique(prefix)
    "#{prefix}_#{SecureRandom.hex(4)}"
  end

  def create_user!(role:)
    User.create!(
      email: "#{unique(role)}@example.com",
      password: "Password123!",
      role: role,
      username: unique(role)
    )
  end

  def create_classroom!(teacher:)
    Classroom.create!(
      name: unique("class"),
      teacher: teacher
    )
  end

  def create_student!(username:, classroom:, parent:)
    User.create!(
      email: "#{unique("student")}@example.com",
      password: "Password123!",
      role: "student",
      username: username,
      classroom: classroom,
      parent: parent
    )
  end

  def create_topic!
    Topic.create!(
      title: unique("topic"),
      category: "Multiplication"
    )
  rescue ActiveModel::UnknownAttributeError, ActiveRecord::RecordInvalid
    raise
  end
end
