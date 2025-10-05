import { NumberBlocksHelper } from "./number_blocks_helper.js";

export function runTopic40WithoutTimer() {
  const gameContainer = document.getElementById('game-container');
  const userSignedIn = gameContainer.dataset.userSignedIn == "true";
  let answer = 0;
  let userAnswer = 0;
  let firstPart = 0;
  let secondPart = 0;
  let previousMultipleOfTen = 0;
  let questionStep = ""; // "1" = cross out units, "2" = type answer
  let controller = null;
  let regroupingDone = false;

  const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');

  if (!gameContainer) {
    console.error("Game container not found");
    return;
  }

  // Clear container
  gameContainer.innerHTML = '';
  gameContainer.style.display = "block";

  // Build UI
  const gameContent = document.createElement('div');
  gameContent.innerHTML = `
    <div class="devise-form form-table">
      <div class="form-table">
        <div id="question-section">
          <h2 id="question-text"></h2>
          <div id="bar-model-container"></div>
          <input type="number" id="answer-input" style="display: none;" />
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

  // Show input and button
  submitAnswerBtn.style.display = "block";

  // Attach listeners once
  submitAnswerBtn.addEventListener("click", submitAnswer);
  answerInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      event.preventDefault();
      submitAnswer();
    }
  });
  returnToTopicIndexBtn.addEventListener("click", () => {
    window.location.href = "/topics/40";
  });

  // Start first question
  generateQuestion();

  function generateQuestion() {
    questionStep = "1";
    regroupingDone = false;
    feedback.textContent = "";

    // Destroy previous controller
    if (controller) {
      controller.destroy();
      controller = null;
    }

    // Generate firstPart and secondPart to avoid regrouping
    firstPart = Math.floor(Math.random() * (99 - 11 + 1)) + 11;
    previousMultipleOfTen = Math.floor(firstPart / 10) * 10;

    const maxSecondPart = firstPart - previousMultipleOfTen - 1; // largest allowed to avoid regroup
    if (maxSecondPart < 1) {
      return generateQuestion(); // retry if impossible
    }

    secondPart = Math.floor(Math.random() * maxSecondPart) + 1;
    answer = firstPart - secondPart;

    questionText.innerHTML = `${firstPart} - ${secondPart} = `;

    // Hide input until Step 1 is complete
    answerInput.style.display = "none";

    // Generate number blocks for Step 1
    generateNumberBlockActivity();
  }

  function generateNumberBlockActivity() {
    if (controller) controller.destroy();

    controller = new NumberBlocksHelper(
      "subtraction",
      firstPart,
      secondPart,
      modelContainer,
      handleComplete
    );
  }

  function handleComplete(isCorrect) {
    // Step 1 (crossing out units) done
    regroupingDone = true;
    generateFinalPart();
  }

  function generateFinalPart() {
    questionStep = "2";
    if (controller && controller.controlsDiv) {
      controller.controlsDiv.style.display = "none";
    }
    answerInput.style.display = "block";
    answerInput.value = '';
    answerInput.focus();
  }

  function submitAnswer() {
    if (questionStep === "1") {
      const onesStruckCount = controller.struck.ones.filter(v => v === true).length;
      if (onesStruckCount < secondPart) {
          feedback.textContent = "Please cross out all unit blocks first!";
          return;
      }

      // Step 1 complete
      questionStep = "2";
      generateFinalPart();
      return;
    }

    // Step 2: check user input
    userAnswer = parseInt(answerInput.value, 10);
    if (userAnswer === answer) {
      feedback.textContent = "Correct!";
      tada.currentTime = 0;
      tada.play();
      setTimeout(generateQuestion, 500);
    } else {
      feedback.textContent = "Try again!";
    }
  }
}