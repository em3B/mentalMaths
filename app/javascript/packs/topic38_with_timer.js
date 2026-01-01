import { NumberBlocksHelper } from "./number_blocks_helper.js";

export function runTopic38WithTimer() {
  const gameContainer = document.getElementById("game-container");
  const userSignedIn = gameContainer.dataset.userSignedIn == "true";
  let totalQuestions = 0;
  let correctAnswers = 0;
  let answer = 0;
  let userAnswer = 0;
  let currentQuestionCounted = false;
  let firstPart = 0;
  let secondPart = 0;
  let controller = null;
  const tada = new Audio(
    "https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3"
  );

  if (!gameContainer) {
    console.error("Game container not found");
    return;
  }

  // Clear existing content
  gameContainer.innerHTML = "";
  gameContainer.style.display = "block";

  // Build UI
  const gameContent = document.createElement("div");
  gameContent.innerHTML = `
    <div class="devise-form form-table">
      <div class="form-table">
        <div id="question-section">
          <p>You have <span id="timer">60</span> seconds.</p>
          <h2 id="question-text"></h2>
          <div id="bar-model-container"></div>
          <label for="answer-input" class="visually-hidden">Answer to the maths question</label>
          <input type="number" id="answer-input" />
          <button class="devise-btn" id="submit-answer-btn">Next</button>
          <h4 id="feedback"></h4>
          <button class="devise-btn" id="go-to-topic-index">Return to Topic</button>
        </div>
      </div>
    </div>
  `;
  gameContainer.appendChild(gameContent);

  let timeLeft = 60;
  let timerInterval;

  const questionText = document.getElementById("question-text");
  const answerInput = document.getElementById("answer-input");
  const submitAnswerBtn = document.getElementById("submit-answer-btn");
  const feedback = document.getElementById("feedback");
  const timerDisplay = document.getElementById("timer");
  const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");
  const modelContainer = document.getElementById("bar-model-container");

  returnToTopicIndexBtn.style.display = "none";

  // Attach listeners once
  submitAnswerBtn.addEventListener("click", submitAnswer);
  answerInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      event.preventDefault();
      submitAnswer();
    }
  });

  generateQuestion();
  startTimer();

  function startTimer() {
    timeLeft = 60;
    timerDisplay.textContent = timeLeft;
    timerInterval = setInterval(() => {
      timeLeft--;
      timerDisplay.textContent = timeLeft;
      if (timeLeft <= 0) {
        clearInterval(timerInterval);
        endGame();
      }
    }, 1000);
  }

  function generateQuestion() {
    // Destroy previous controller
    if (controller) {
      controller.destroy();
      controller = null;
    }

    // Generate numbers safely
    firstPart = Math.floor(Math.random() * 89) + 11; // 11–99
    const nextMultipleOfTen = Math.ceil(firstPart / 10) * 10;
    const maxSecondPart = nextMultipleOfTen - firstPart - 1;
    secondPart = Math.floor(Math.random() * maxSecondPart) + 1;

    answer = firstPart + secondPart;
    questionText.innerHTML = `${firstPart} + ${secondPart} = `;

    // Reset input
    answerInput.value = "";
    answerInput.focus();

    // Create new controller
    controller = new NumberBlocksHelper(
      "addition",
      firstPart,
      secondPart,
      modelContainer,
      handleComplete
    );
  }

  function handleComplete(isCorrect) {
    if (isCorrect) userAnswer = answer;
  }

  function submitAnswer() {
    userAnswer = parseInt(answerInput.value, 10);

    if (userAnswer === answer) {
      feedback.textContent = "Correct!";
      correctAnswers++;
      totalQuestions++;

      tada.currentTime = 0;
      tada.play();

      generateQuestion();
    } else {
      if (!currentQuestionCounted) {
        totalQuestions++;
        currentQuestionCounted = true;
      }
      feedback.textContent = "Try again!";
    }

    currentQuestionCounted = false;
  }

  function endGame() {
    questionText.textContent = "";
    answerInput.style.display = "none";
    submitAnswerBtn.style.display = "none";
    feedback.innerHTML = `
      <strong>Time's up!</strong><br><br>
      Game over! You scored ${correctAnswers}/${totalQuestions}.
    `;
    returnToTopicIndexBtn.style.display = "inline-block";

    if (userSignedIn) {
      updateScore(correctAnswers, totalQuestions);
    }

    returnToTopicIndexBtn.onclick = () => {
      window.location.href = "/topics/38";
    };
  }

  function updateScore(correct, totalQuestions) {
    fetch("/scores", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
      body: JSON.stringify({
        score: {
          correct: correct,
          total: totalQuestions,
          topic_id: 38,
        },
      }),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        console.log("Score successfully saved:", data);
      })
      .catch((error) => {
        console.error("Error saving score:", error);
      });
  }
}