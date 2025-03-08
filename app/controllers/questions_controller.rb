class QuestionsController < ApplicationController
  def show
    @topic = Topic.find(params[:id])
    @question = @topic.questions.order("RANDOM()").first
  end

  def answer
    question = Question.find(params[:id])
    user_answer = params[:value].to_i

    # Update session score
    session[:score] += 1 if user_answer == question.correct_answer
  end

  def score
    @score = session[:score]
    session.delete(:questions) # Clear session data
    session.delete(:score)
  end
end
