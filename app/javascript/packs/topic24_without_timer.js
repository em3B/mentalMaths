(function runGame() {
    const gameContainer = document.getElementById('game-container');
    let nextValue = 0;
  
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
          <div id="question-section" style="display: none;">
            <p id="question-text"></p>
            <input type="number" id="answer-input" />
            <button class="devise-btn" id="submit-answer-btn">Next</button>
            <button class="devise-btn" id="go-to-topic-index">End Game</button>
            <p id="feedback"></p>
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
    const endGameBtn = document.getElementById("go-to-topic-index");
  
    // Listen to the start number and step amount set by the user, make sure valid
    const startNumber = parseInt(0, 10);
    step = parseInt(11, 10);

    if (isNaN(startNumber) || startNumber < 0) {
    alert("Please enter valid numbers.");
    return;
    }

    // Initial setup from the user input
    currentValue = startNumber;

    // Hide setup, show game
    questionSection.style.display = "block";
    generateQuestion();
  
  
    function generateQuestion() {
      // Decide randomly to add or subtract
      const direction = Math.random() < 0.5 ? -1 : 1;
      nextValue = currentValue + (step * direction);
  
      // Clamp to 0–200
      if (nextValue < 0 || nextValue > 132) {
        nextValue = currentValue + (step * -direction); // flip direction
      }
  
      questionText.innerHTML = `<h2>${currentValue} ${nextValue > currentValue ? "+" : "-"} ${step} = </h2>`;
      answerInput.value = '';
      answerInput.focus();
    }

    submitAnswerBtn.onclick = () => {
      const userAnswer = parseInt(answerInput.value, 10);
      if (userAnswer === nextValue) {
        feedback.textContent = "Correct!";

        confetti({
          particleCount: 80,
          spread: 110,
          origin: { y: 0.6 }
        });

        const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
        tada.play();
        
        currentValue = nextValue;
        generateQuestion();
      } else {
        feedback.textContent = "Try again!";
      }
    };

    answerInput.addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        submitAnswerBtn.click();
      }
    });
  
    endGameBtn.onclick = () => {
      window.location.href = '/topics/24';
    }
  
  })();
  