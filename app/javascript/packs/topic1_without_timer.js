(function runGame() {
    const gameContainer = document.getElementById('game-container');
    let answer = 0;
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

    // Hide setup, show game
    questionSection.style.display = "block";
    generateQuestion();
  
  
    function generateQuestion() {
        // Generate first addend for the question (1-10 inclusive)
        firstAddend = Math.floor(Math.random() * 11);
        answer = 10 - firstAddend;
        questionText.innerHTML = `<h2>${firstAddend} + __ = 10</h2>`;
        answerInput.value = '';
        answerInput.focus();
    }

    submitAnswerBtn.onclick = () => {
      const userAnswer = parseInt(answerInput.value, 10);
      if (userAnswer == answer) {
      feedback.textContent = "Correct!";

      confetti({
        particleCount: 80,
        spread: 110,
        origin: { y: 0.6 }
      });

      tada.currentTime = 0;
      tada.play();
      
      generateQuestion();
      } else {
      feedback.textContent = "Try again!";
      }
  };

  answerInput.onkeydown = (event) => {
    if (event.key === 'Enter') submitAnswerBtn.click();
  };
  
    endGameBtn.onclick = () => {
      window.location.href = '/topics/1';
    }
  
  })();
  