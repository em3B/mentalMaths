(function runGame() {
  const gameContainer = document.getElementById('game-container');
  const userSignedIn = gameContainer.dataset.userSignedIn == "true";
  let totalQuestions = 0; 
  let correctAnswers = 0;

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
    <div class="devise-form">
      <div class="form-table" id="game-content">
        <label id="start-input">Start Number: <input type="number" id="start-number" min="0" max="200" required></label><br>
        <label id="step-input">Count By: <input type="number" id="step-amount" min="1" max="200" required></label><br><br>
        <button class="devise-btn" id="start-game-btn">Start Game</button>
        <div id="question-section" style="display: none;">
          <p>You have <span id="timer">60</span> seconds.</p>
          <p id="question-text"></p>
          <input type="number" id="answer-input" />
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
  const startGameBtn = document.getElementById("start-game-btn");
  const questionText = document.getElementById("question-text");
  const answerInput = document.getElementById("answer-input");
  const submitAnswerBtn = document.getElementById("submit-answer-btn");
  const feedback = document.getElementById("feedback");
  const timerDisplay = document.getElementById("timer");
  const startInput = document.getElementById("start-input");
  const stepInput = document.getElementById("step-input");
  const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");

  // Listen to the start number and step amount set by the user, make sure valid
  startGameBtn.addEventListener("click", () => {
    const startNumber = parseInt(document.getElementById("start-number").value, 10);
    const stepAmount = parseInt(document.getElementById("step-amount").value, 10);

    if (isNaN(startNumber) || isNaN(stepAmount) || startNumber < 0 || stepAmount <= 0) {
      alert("Please enter valid numbers.");
      return;
    }

    // Initial setup from the user input
    currentValue = startNumber;
    step = stepAmount;

    // Hide setup, show game
    startGameBtn.style.display = "none";
    document.getElementById("start-number").style.display = "none";
    document.getElementById("step-amount").style.display = "none";
    returnToTopicIndexBtn.style.display = "none";
    startInput.textContent = '';
    stepInput.textContent = '';
    questionSection.style.display = "block";
    generateQuestion();
    startTimer();
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

  function generateQuestion() {
    // Decide randomly to add or subtract
    const direction = Math.random() < 0.5 ? -1 : 1;
    let nextValue = currentValue + (step * direction);

    // Clamp to 0–200
    if (nextValue < 0 || nextValue > 200) {
      nextValue = currentValue + (step * -direction); // flip direction
    }

    questionText.innerHTML = `<h2>${currentValue} ${nextValue > currentValue ? "+" : "-"} ${step} = </h2>`;
    answerInput.value = '';
    answerInput.focus();

    submitAnswerBtn.onclick = () => {
      const userAnswer = parseInt(answerInput.value, 10);
      if (userAnswer === nextValue) {
        feedback.textContent = "Correct!";
        correctAnswers += 1;
        totalQuestions += 1;
        currentValue = nextValue;
        generateQuestion();
      } else {
        totalQuestions += 1;
        feedback.textContent = "Try again!";
      }
    };
  }

  function endGame() {
    questionText.textContent = '';
    answerInput.style.display = 'none';
    submitAnswerBtn.style.display = 'none';
    startInput.textContent = '';
    stepInput.textContent = '';
    feedback.innerHTML = `<strong>Time's up!</strong>`;
    feedback.textContent = `Game over! You scored ${correctAnswers}/${totalQuestions}`;
    returnToTopicIndexBtn.style.display = "inline-block";

    if (userSignedIn) {
      updateScore(correctAnswers, totalQuestions);
    }

    returnToTopicIndexBtn.onclick = () => {
      window.location.href = '/topics/12'
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
          total_questions: totalQuestions
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
})();
