import { NumberBlocksHelper } from "./number_blocks_helper.js";

export function runTopic41WithoutTimer() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let answer = 0;
    let userAnswer = 0;
    let firstPart = 0;
    let secondPart = 0;
    let previousMultipleOfTen = 0;
    let questionStep = "";
    let controller = null;
    const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
    let regroupingDone = false;
  
    if (!gameContainer) {
      console.error("Game container not found");
      return;
    }
  
    // Clear any existing content
    gameContainer.innerHTML = '';
    gameContainer.style.display = "block";
  
    // Create form for inputs
    const gameContent = document.createElement('div');
    gameContent.innerHTML = `
    <div class="devise-form form-table">
        <div class="form-table">
        <div id="question-section">
            <h2 id="question-text"></h2>
            <h4 id="step-instruction" style="color: #d17b00; font-weight: 600; margin-top: 8px;"></h4>
            <div id="bar-model-container"></div>
            <label for="answer-input" class="visually-hidden">Answer to the maths question</label>
            <input type="number" id="answer-input" style="display: none;" />
            <button class="devise-btn" id="submit-answer-btn">Next</button>
            <h4 id="feedback"></h4>
            <button class="devise-btn" id="go-to-topic-index">Return to Topic</button>
        </div>
        </div>
    </div>
    `;
    gameContainer.appendChild(gameContent);
  
    // Possible Inputs from innerHtml
    const questionSection = document.getElementById("question-section");
    const questionText = document.getElementById("question-text");
    const answerInput = document.getElementById("answer-input");
    const submitAnswerBtn = document.getElementById("submit-answer-btn");
    const feedback = document.getElementById("feedback");
    const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");
    const modelContainer = document.getElementById("bar-model-container");
    const stepInstruction = document.getElementById("step-instruction");

    // Hide setup, show game
    questionSection.style.display = "block";
    generateQuestion();

  // Attach listeners once
    submitAnswerBtn.addEventListener("click", submitAnswer);
    answerInput.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
        event.preventDefault();
        submitAnswer();
        }
    });
    returnToTopicIndexBtn.addEventListener("click", () => {
        window.location.href = "/topics/41";
    });
  
  function generateQuestion() {
    // Pick a random 2-digit number that’s not a multiple of 10
    do {
      firstPart = Math.floor(Math.random() * (99 - 11 + 1)) + 11; // 11–99
    } while (firstPart % 10 === 0); // avoid multiples of 10 (like 20, 30...)

    previousMultipleOfTen = Math.floor(firstPart / 10) * 10;

    // Build a list of valid "secondPart" options that force regrouping
    const possibleSeconds = [];
    for (let i = 1; i <= 9; i++) {
      if (firstPart - i < previousMultipleOfTen) {
        possibleSeconds.push(i);
      }
    }

    // If no regrouping possible, regenerate
    if (possibleSeconds.length === 0) {
      generateQuestion(); // try again with a new firstPart
      return;
    }

    // Pick one valid "secondPart" from the list
    secondPart = possibleSeconds[Math.floor(Math.random() * possibleSeconds.length)];

    // Compute answer and render the question
    answer = firstPart - secondPart;
    questionText.innerHTML = `${firstPart} - ${secondPart} = `;
    answerInput.style.display = "none";
    submitAnswerBtn.style.display = "block";

    generateNumberBlockActivity();
  }

    function generateNumberBlockActivity() {
        questionStep = "1";
        if (controller) controller.destroy();
        controller = new NumberBlocksHelper("subtraction", firstPart, secondPart, modelContainer, handleComplete, true);
        stepInstruction.textContent = "Click the orange ten rod";
    }

    function handleComplete(isCorrect) {
        regroupingDone = true;
        stepInstruction.textContent = ""; 
        generateFinalPart();
    }

  function generateFinalPart() {
    questionStep = "2";
    answerInput.style.display = "block"; 
    submitAnswerBtn.style.display = "block";
    answerInput.value = '';
    answerInput.focus();
  }

  function submitAnswer() {
    if (questionStep === "1") {
      const onesStruckCount = controller.struck.ones.filter(v => v === true).length;
      if (onesStruckCount < secondPart) {
          feedback.textContent = "Please regroup first by clicking the last ten rod!";
          return;
      }

      // Step 1 complete
      questionStep = "2";
      generateFinalPart();
      return;
    }

    userAnswer = parseInt(answerInput.value, 10);
    if (userAnswer === answer) {
    feedback.textContent = "Correct!";

    tada.play();
    setTimeout(generateQuestion, 500);
    } else {
    feedback.textContent = "Try again!";
    }
  }  
  
}