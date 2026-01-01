(function runGame() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let totalQuestions = 0; 
    let correctAnswers = 0;
    let tenFrameValue = 0;
    let currentQuestionCounted = false;
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
            <p>You have <span id="timer">60</span> seconds.</p>
            <img id="question-image" src="" style="width: 300px; height: auto; object-fit: contain; visibility: hidden;">
            <label for="answer-input" class="visually-hidden">Answer to the maths question</label>
            <input type="number" id="answer-input" />
            <button class="devise-btn" id="submit-answer-btn">Next</button>
            <h4 id="feedback"></h4>
            <button class="devise-btn" id="go-to-topic-index">Return to Topic</button>
          </div>
        </div>
      </div>
    `;
    gameContainer.appendChild(gameContent);
  
    let timeLeft = 60, timerInterval;
  
    // Possible Inputs from innerHtml
    const questionSection = document.getElementById("question-section");
    const questionImage = document.getElementById("question-image");
    const answerInput = document.getElementById("answer-input");
    const submitAnswerBtn = document.getElementById("submit-answer-btn");
    const feedback = document.getElementById("feedback");
    const timerDisplay = document.getElementById("timer");
    const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");

    // Hide setup, show game
    questionSection.style.display = "block";
    generateQuestion();
    startTimer();

    returnToTopicIndexBtn.onclick = () => {
        window.location.href = '/topics/8';
      }
  
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
        // Generate image to use
        index = Math.floor(Math.random() * 10);
        tenFrameValue = displayTenFrameAndReturnValue(index) + 1;
        answerInput.value = '';
        answerInput.focus();
    }

    submitAnswerBtn.onclick = () => {
        const userAnswer = parseInt(answerInput.value, 10);
        if (userAnswer === tenFrameValue) {
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
        
        // Hide image after 2 seconds, then load next question
        setTimeout(() => {
            questionImage.style.visibility = 'hidden';
            generateQuestion();
        }, 2000);
        } else {
        if (!currentQuestionCounted) {
            totalQuestions += 1;
            currentQuestionCounted = true;
          }
        feedback.textContent = "Try again!";
        }

        currentQuestionCounted = false;
    };

  answerInput.onkeydown = (event) => {
    if (event.key === 'Enter') submitAnswerBtn.click();
  };

    function displayTenFrameAndReturnValue(index) {
        // images to use
        const images = [
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453454/MentalMaths/frame1_losp5u.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453454/MentalMaths/frame2_ibpscb.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453454/MentalMaths/frame3_f9v5l6.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453454/MentalMaths/frame4_ettqyq.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453454/MentalMaths/frame5_u4efva.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453454/MentalMaths/frame6_ioiziu.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453459/MentalMaths/frame7_bzukoc.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453459/MentalMaths/frame8_rjlp72.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453460/MentalMaths/frame9_myg7pl.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746453463/MentalMaths/frame10_gbvrbx.png"
        ]

        questionImage.src = images[index];
        questionImage.style.visibility = 'visible';

        setTimeout(() => {
        questionImage.style.visibility = 'hidden';
        }, 2000);

        return index;
    }
  
    function endGame() {
      questionImage.style.display = 'none';
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
        window.location.href = '/topics/8';
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
            topic_id: 8
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
  