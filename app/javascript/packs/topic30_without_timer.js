(function runGame() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let totalQuestions = 0; 
    let correctAnswers = 0;
    let answer = 0;
    let nextMultipleOfTen = 0;
    let twoDigitNumber = 0;
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
          <div id="question-section" style="display: none;">
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
        twoDigitNumber = Math.floor(Math.random() * 99) + 1;
        nextMultipleOfTen = Math.ceil((twoDigitNumber + 1) / 10) * 10;
        answer = nextMultipleOfTen - twoDigitNumber;
        questionText.innerHTML = `<h2>${twoDigitNumber} + _____ = ${nextMultipleOfTen}</h2>`;
        answerInput.value = '';
        answerInput.focus();
    }

    submitAnswerBtn.onclick = () => {
      const userAnswer = parseInt(answerInput.value, 10);
      if (userAnswer === answer) {
      feedback.textContent = "Correct!";
      correctAnswers += 1;
      totalQuestions += 1;
      
      confetti({
        particleCount: 80,
        spread: 110,
        origin: { y: 0.6 }
      });

      tada.currentTime = 0;
      tada.play();
      
        // Delay next question so feedback is visible
        setTimeout(() => {
          generateQuestion();
          feedback.textContent = ""; // clear feedback after next question loads
          answerInput.value = "";    // clear input for next question
        }, 1500); 
      } else {
      feedback.textContent = "Try again!";
      }
  };

  answerInput.onkeydown = (event) => {
    if (event.key === 'Enter') submitAnswerBtn.click();
  };
  
    endGameBtn.onclick = () => {
      window.location.href = '/topics/30';
    }
  })();
  