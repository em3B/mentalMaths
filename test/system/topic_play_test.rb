require "application_system_test_case"

class TopicPlayTest < ApplicationSystemTestCase
  setup do
    @topic = Topic.create!(
      title: "Times Tables",
      category: "Multiplication",
      requires_auth: false
    )
  end

  test "guest can open play page and start game UI" do
    visit play_topic_path(@topic)

    assert_text @topic.title
    assert_button "Play"

    # Timer checkbox exists and is visible BEFORE clicking Play
    assert_selector "#use-timer", visible: true
    assert_text "Use Timer"

    # Container starts hidden
    assert_selector "#game-container", visible: :hidden

    click_button "Play"

    # After clicking, the form hides (so timer checkbox won't be visible anymore)
    assert_selector ".devise-form", visible: :hidden

    # Game container becomes visible
    assert_selector "#game-container", visible: true
  end

  test "guest can start game UI with timer enabled" do
    visit play_topic_path(@topic)

    assert_selector "#use-timer", visible: true
    check "Use Timer"

    click_button "Play"
    assert_selector "#game-container", visible: true
  end
end
