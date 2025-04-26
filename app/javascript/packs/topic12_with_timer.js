(function runGame() {
  const gameContainer = document.getElementById('game-container');

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
      <p>Set your game:</p>
      <div class="form-table" id="game-content">
        <label>Start Number: <input type="number" id="start-number" min="0" max="200" required></label><br>
        <label>Count By: <input type="number" id="step-amount" min="1" max="200" required></label><br><br>
        <button class="devise-btn" id="start-game-btn">Start Game</button>
        <div id="question-section" style="display: none;">
          <p>You have <span id="timer">60</span> seconds.</p>
          <p id="question-text"></p>
          <input type="number" id="answer-input" />
          <button class="devise-btn" id="submit-answer-btn">Submit</button>
          <p id="feedback"></p>
        </div>
      </div>
    </div>
  `;
  gameContainer.appendChild(gameContent);

  let currentValue, step, timeLeft = 60, timerInterval;

  const questionSection = document.getElementById("question-section");
  const startGameBtn = document.getElementById("start-game-btn");
  const questionText = document.getElementById("question-text");
  const answerInput = document.getElementById("answer-input");
  const submitAnswerBtn = document.getElementById("submit-answer-btn");
  const feedback = document.getElementById("feedback");
  const timerDisplay = document.getElementById("timer");

  startGameBtn.addEventListener("click", () => {
    const startNumber = parseInt(document.getElementById("start-number").value, 10);
    const stepAmount = parseInt(document.getElementById("step-amount").value, 10);

    if (isNaN(startNumber) || isNaN(stepAmount) || startNumber < 0 || stepAmount <= 0) {
      alert("Please enter valid numbers.");
      return;
    }

    currentValue = startNumber;
    step = stepAmount;

    // Hide setup, show game
    startGameBtn.style.display = "none";
    document.getElementById("start-number").style.display = "none";
    document.getElementById("step-amount").style.display = "none";
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

    questionText.textContent = `What is ${currentValue} ${nextValue > currentValue ? "+" : "-"} ${step}?`;
    answerInput.value = '';
    answerInput.focus();

    submitAnswerBtn.onclick = () => {
      const userAnswer = parseInt(answerInput.value, 10);
      if (userAnswer === nextValue) {
        feedback.textContent = "Correct!";
        currentValue = nextValue;
        generateQuestion();
      } else {
        feedback.textContent = "Try again!";
      }
    };
  }

  function endGame() {
    questionText.textContent = '';
    answerInput.style.display = 'none';
    submitAnswerBtn.style.display = 'none';
    feedback.innerHTML = `<strong>Time's up!</strong>`;
  }
})();
