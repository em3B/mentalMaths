(function runGame() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let totalQuestions = 0; 
    let correctAnswers = 0;
    let nextValue = 0;
    let currentQuestionCounted = false;
  
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
        <div class="form-table">
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
    const questionText = document.getElementById("question-text");
    const answerInput = document.getElementById("answer-input");
    const submitAnswerBtn = document.getElementById("submit-answer-btn");
    const feedback = document.getElementById("feedback");
    const timerDisplay = document.getElementById("timer");
    const startInput = document.getElementById("start-input");
    const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");
  
    // Listen to the start number and step amount set by the user, make sure valid
    const startNumber = parseInt(0, 10);
    step = parseInt(4, 10);

    if (isNaN(startNumber) || startNumber < 0) {
    alert("Please enter valid numbers.");
    return;
    }

    // Initial setup from the user input
    currentValue = startNumber;

    // Hide setup, show game
    returnToTopicIndexBtn.style.display = "none";
    questionSection.style.display = "block";
    generateQuestion();
    startTimer();
  
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
      nextValue = currentValue + (step * direction);
  
      // Clamp to 0–200
      if (nextValue < 0 || nextValue > 48) {
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
        correctAnswers += 1;
        totalQuestions += 1;

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
        if (!currentQuestionCounted) {
            totalQuestions += 1;
            currentQuestionCounted = true;
          }
        feedback.textContent = "Try again!";
      }

      currentQuestionCounted = false;
    };

    answerInput.addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        submitAnswerBtn.click();
      }
    });
  
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
        window.location.href = '/topics/17';
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
            topic_id: 17
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
  