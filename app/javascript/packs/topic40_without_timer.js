import { NumberBlocksHelper } from "./number_blocks_helper.js";

(function runGame() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let answer = 0;
    let userAnswer = 0;
    let firstPart = 0;
    let secondPart = 0;
    let previousMultipleOfTen = 0;
    let questionStep = "";
    let controller;
    const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
  
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
  
    // Possible Inputs from innerHtml
    const questionSection = document.getElementById("question-section");
    const questionText = document.getElementById("question-text");
    const answerInput = document.getElementById("answer-input");
    const submitAnswerBtn = document.getElementById("submit-answer-btn");
    const feedback = document.getElementById("feedback");
    const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");
    const modelContainer = document.getElementById("bar-model-container");

    // Hide setup, show game
    questionSection.style.display = "block";
    generateQuestion();

    function generateQuestion() {
        do {
            firstPart = Math.floor(Math.random() * (99 - 11 + 1)) + 11;
        } while (firstPart == 0);
        previousMultipleOfTen = Math.floor(firstPart / 10) * 10;
        do {
            secondPart = Math.floor(Math.random() * 11);
        } while (secondPart == 0 || (firstPart - secondPart <= previousMultipleOfTen));
        answer = firstPart - secondPart;
        questionText.innerHTML =`${firstPart} - ${secondPart} = `;
        answerInput.style.display = "none"; 
        submitAnswerBtn.style.display = "none";

        generateNumberBlockActivity();
    }

    function generateNumberBlockActivity() {
        questionStep = "1";
        controller = new NumberBlocksHelper("subtraction", firstPart, secondPart, modelContainer, (isCorrect) => {
            if (isCorrect == true) {
                userAnswer = answer;
            }
            submitAnswer();
        })
    }

    submitAnswerBtn.onclick = () => {
      submitAnswer();
  };

  function generateFinalPart() {
    questionStep = "2";
    controller.controlsDiv.style.display = "none";
    answerInput.style.display = "block"; 
    submitAnswerBtn.style.display = "block";
    answerInput.value = '';
    answerInput.focus();
  }

  function submitAnswer() {
    if (questionStep == "2") {
      userAnswer = parseInt(answerInput.value, 10);
    }
    if (userAnswer === answer) {
    feedback.textContent = "Correct!";
    
    confetti({
      particleCount: 80,
      spread: 110,
      origin: { y: 0.6 }
    });

    tada.currentTime = 0;
    tada.play();
    
    if (questionStep == "1") {
      generateFinalPart();
    } else {
      generateQuestion();
    }
    } else {
    feedback.textContent = "Try again!";
    }
  }

  answerInput.onkeydown = (event) => {
    if (event.key === 'Enter') submitAnswerBtn.click();
  };

    returnToTopicIndexBtn.onclick = () => {
      window.location.href = '/topics/40';
    }
  
  })();
  