import { NumberBlocksHelper } from "./number_blocks_helper.js";

export function runTopic39WithoutTimer() {
  const gameContainer = document.getElementById("game-container");
  const userSignedIn = gameContainer.dataset.userSignedIn == "true";
  let answer = 0;
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

  // Clear any existing content
  gameContainer.innerHTML = "";
  gameContainer.style.display = "block";

  // Build UI
  const gameContent = document.createElement("div");
  gameContent.innerHTML = `
    <div class="devise-form form-table">
      <div class="form-table">
        <div id="question-section">
          <h2 id="question-text"></h2>
          <div id="bar-model-container"></div>
          <label for="answer-input" class="visually-hidden">Answer to the maths question</label>
          <input type="number" id="answer-input"/>
          <button class="devise-btn" id="submit-answer-btn">Next</button>
          <h4 id="feedback"></h4>
          <button class="devise-btn" id="go-to-topic-index">Return to Topic</button>
        </div>
      </div>
    </div>
  `;
  gameContainer.appendChild(gameContent);

  // DOM references
  const questionText = document.getElementById("question-text");
  const answerInput = document.getElementById("answer-input");
  const submitAnswerBtn = document.getElementById("submit-answer-btn");
  const feedback = document.getElementById("feedback");
  const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");
  const modelContainer = document.getElementById("bar-model-container");

  submitAnswerBtn.style.display = "block";
  answerInput.style.display = "block";

  // Attach listeners once
  submitAnswerBtn.addEventListener("click", submitAnswer);
  answerInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      event.preventDefault();
      submitAnswer();
    }
  });
  returnToTopicIndexBtn.addEventListener("click", () => {
    window.location.href = "/topics/39";
  });

  // Start the game
  generateQuestion();

  function generateQuestion() {
    // Destroy previous controller
    if (controller) {
      controller.destroy();
      controller = null;
    }

    // firstPart: 11–99, not a multiple of 10
    do {
      firstPart = Math.floor(Math.random() * 89) + 11;
    } while (firstPart % 10 === 0);

    // next multiple of 10 above firstPart
    const nextMultipleOfTen = Math.ceil(firstPart / 10) * 10;

    // secondPart: force result to cross next multiple of ten
    const minSecondPart = nextMultipleOfTen - firstPart + 1; // ensure crossing
    const maxSecondPart = 9;

    if (minSecondPart > maxSecondPart) {
      // edge case, regenerate firstPart
      return generateQuestion(); // restart safely
    }

    secondPart = Math.floor(Math.random() * (maxSecondPart - minSecondPart + 1)) + minSecondPart;

    answer = firstPart + secondPart;
    questionText.innerHTML = `${firstPart} + ${secondPart} = `;

    generateNumberBlockActivity();
  }

  function generateNumberBlockActivity() {
    if (controller) controller.destroy();

    controller = new NumberBlocksHelper(
      "addition",
      firstPart,
      secondPart,
      modelContainer,
      handleComplete, // regrouping callback
      true            // regrouping involved
    );
  }

  function handleComplete(isCorrect) {
    if (isCorrect) {
      // regrouping done properly, now show input
      answerInput.style.display = "block";
      submitAnswerBtn.style.display = "block";
      answerInput.value = "";
      answerInput.focus();
    }
  }

  function submitAnswer() {
    const typedValue = parseInt(answerInput.value, 10);

    if (typedValue == answer) {
      feedback.textContent = "Correct!";

      tada.currentTime = 0;
      tada.play();

      generateQuestion();
    } else {
      feedback.textContent = "Try again!";
    }
  }
}