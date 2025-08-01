import { names, items, templates, getPronouns } from "./wordProblemHelper";
import { BarModelHelper } from "./bar_model_helper.js";

(function runGame() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let totalQuestions = 0; 
    let correctAnswers = 0;
    let answer = 0;
    let currentQuestionCounted = false;
    let firstPart = 0;
    let secondPart = 0;
    let total = 0;
    let name = "";
    let item = "";
    let templateQuestion = "";
    let templateIndex = 0;
  
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
        templateIndex = Math.floor(Math.random() * 2);
        do {
            firstPart = Math.floor(Math.random() * 11);
        } while (firstPart == 0);
        do {
            secondPart = Math.floor(Math.random() * 11);
        } while (secondPart == 0);
        total = firstPart + secondPart;
        name = names[Math.floor(Math.random() * names.length)];
        item = items[Math.floor(Math.random() * items.length)];
        let { pronoun, pronounLower } = getPronouns(name);
        if (templateIndex == 0) {
            answer = total - firstPart;
            templateQuestion = templates.partWhole[0]
                .replace("{name}", name)
                .replace("{item}", item)
                .replace("{total}", total)
                .replace("{part}", firstPart)
                .replaceAll("{pronoun}", pronoun)
                .replaceAll("{pronounLower}", pronounLower);
        } else {
            answer = firstPart + secondPart;
            templateQuestion = templates.partWhole[1]
                .replace("{name}", name)
                .replace("{part1}", firstPart)
                .replaceAll("{item}", item)
                .replaceAll("{pronounLower}", pronounLower)
                .replaceAll("{part2}", secondPart)
        }
        questionText.innerHTML = templateQuestion;
        answerInput.style.display = "none"; 
        if (templateIndex == 0) {
            generateSubtractionBarModel();
        } else {
            generateAdditionBarModel();
        }
    }

    function generateSubtractionBarModel() {
        let barModel = new BarModelHelper(modelContainer);
        barModel.loadAddSubModel({
            type: "subtraction",
            total: total,
            part1: firstPart,
            part2: secondPart,
            comparison: false,
            onDropComplete: () => {
              answerInput.style.display = "block";
              answerInput.value = '';
              answerInput.focus();
            }
        });
    }

    function generateAdditionBarModel() {
        let barModel = new BarModelHelper(modelContainer);
        barModel.loadAddSubModel({
            type: "addition",
            total: total,
            part1: firstPart,
            part2: secondPart,
            comparison: false,
            onDropComplete: () => {
              answerInput.style.display = "block";
              answerInput.value = '';
              answerInput.focus();
            }
        });
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

      const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
      tada.play();
      
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
        window.location.href = '/topics/32';
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
            topic_id: 32
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
  