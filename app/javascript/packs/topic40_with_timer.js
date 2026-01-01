import { NumberBlocksHelper } from "./number_blocks_helper.js";

export function runTopic40WithTimer() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let totalQuestions = 0; 
    let correctAnswers = 0;
    let answer = 0;
    let userAnswer = 0;
    let currentQuestionCounted = false;
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
            <p>You have <span id="timer">60</span> seconds.</p>
            <h2 id="question-text"></h2>
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
  
    let currentValue, step, timeLeft = 60, timerInterval;
  
    // Possible Inputs from innerHtml
    const questionSection = document.getElementById("question-section");
    const questionText = document.getElementById("question-text");
    const answerInput = document.getElementById("answer-input");
    const submitAnswerBtn = document.getElementById("submit-answer-btn");
    const feedback = document.getElementById("feedback");
    const timerDisplay = document.getElementById("timer");
    const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");
    const modelContainer = document.getElementById("bar-model-container");

    // Hide setup, show game
    returnToTopicIndexBtn.style.display = "none";
    questionSection.style.display = "block";
    submitAnswerBtn.style.display = "block";
    generateQuestion();
    startTimer();

    submitAnswerBtn.addEventListener("click", submitAnswer);
    answerInput.addEventListener("keydown", (event) => {
      if (event.key === "Enter") {
        event.preventDefault();
        submitAnswer();
      }
    });
  
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

    userAnswer = parseInt(answerInput.value, 10);
    if (userAnswer === answer) {
    feedback.textContent = "Correct!";
    correctAnswers += 1;
    totalQuestions += 1;

    tada.currentTime = 0;
    tada.play();
    setTimeout(generateQuestion, 500);
    } else {
    if (!currentQuestionCounted) {
          totalQuestions += 1;
          currentQuestionCounted = true;
        }
    feedback.textContent = "Try again!";
    }

    currentQuestionCounted = false;
  }
  
    function endGame() {
      questionText.textContent = '';
      answerInput.style.display = 'none';
      submitAnswerBtn.style.display = 'none';
      feedback.innerHTML = `
        <strong>Time's up!</strong><br><br>
        Game over! You scored ${correctAnswers}/${totalQuestions}.
      `;
      returnToTopicIndexBtn.style.display = "inline-block";
    
      if (userSignedIn) {
        updateScore(correctAnswers, totalQuestions);
      }
    
      returnToTopicIndexBtn.onclick = () => {
        window.location.href = '/topics/40';
      }
    }    
  
    function updateScore(correct, totalQuestions) {
      fetch('/scores', {  
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({
          score: {
            correct: correct,
            total: totalQuestions,
            topic_id: 40
          }
        })
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(data => {
        console.log('Score successfully saved:', data);
      })
      .catch(error => {
        console.error('Error saving score:', error);
      });
    }
  };
  