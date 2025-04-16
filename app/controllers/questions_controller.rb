class QuestionsController < ApplicationController
  def show
    @topic = Topic.find(params[:id])
    @question = @topic.questions.order("RANDOM()").first
  end

  def answer
    question = Question.find(params[:id])
    user_answer = params[:value].to_i

    # Save response with user or guest session
    Response.create!(
      question: question,
      value: user_answer,
      user_id: current_user&.id,           # For signed-in users (nil if guest)
      session_id: session.id.to_s          # For guest tracking
    )

    # Update session score
    session[:score] ||= 0
    session[:score] += 1 if user_answer == question.correct_answer

    # You might want to redirect or render something next
    # redirect_to next_question_path or render json: { score: session[:score] }
  end


  def score
    @score = session[:score]
    session.delete(:questions) # Clear session data
    session.delete(:score)
  end
end
