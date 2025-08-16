import { names, items, templates, getPronouns, containers } from "./wordProblemHelper";
import { BarModelHelper } from "./bar_model_helper.js";

(function runGame() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let totalQuestions = 0; 
    let correctAnswers = 0;
    let answer = 0;
    let userAnswer = 0;
    let currentQuestionCounted = false;
    let group = 0;
    let perGroup = 0;
    let total = 0;
    let item = "";
    let container = "";
    let templateQuestion = "";
    let templateIndex = 0;
    let type = "";
  
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
            group = Math.floor(Math.random() * 11);
        } while (group == 0);
        do {
            perGroup = Math.floor(Math.random() * 11);
        } while (perGroup == 0);
        total = group * perGroup;
        name = names[Math.floor(Math.random() * names.length)];
        item = items[Math.floor(Math.random() * items.length)];
        if (templateIndex == 0) {
            answer = group;
            container = containers[Math.floor(Math.random() * containers.length)];
            templateQuestion = templates.multiplicative[0]
                .replace("{groups}", group)
                .replace("{container}", container)
                .replaceAll("{item}", item)
                .replace("{perGroup}", perGroup);

        } else {
          console.log("total: " + total);
            answer = total / group;
            let { pronoun, pronounLower } = getPronouns(name);
            templateQuestion = templates.multiplicative[1]
                .replace("{name}", name)
                .replace("{total}", total)
                .replaceAll("{item}", item)
                .replace("{pronoun}", pronoun)
                .replace("{groups}", group);
        }
        questionText.innerHTML = templateQuestion;
        answerInput.style.display = "none"; 
        submitAnswerBtn.style.display = "none";

        if (templateIndex == 0) {
            generateMultiplicationBarModel();
        } else {
            generateDivisionBarModel();
        }
    }

    function generateMultiplicationBarModel() {
      let barModel = new BarModelHelper(modelContainer);
      type = "multiplication1";

      // ✅ Store return value
      const controller = barModel.loadMultiplicationModel({
        groups: group,
        unit: perGroup,
        onComplete: () => {
          const barCount = controller.getBarCount();
          userAnswer = barCount;
          submitAnswer();
        }
      });
    }

    function generateDivisionBarModel() {
        type = "division";
        let barModel = new BarModelHelper(modelContainer);
        const controller = barModel.loadDivisionModel({
            groups: group,
            unit: perGroup,
            onComplete: () => {
              if (controller.isCorrect == true) {
                userAnswer = answer;
              } else {
                userAnswer = 0;
              }
              submitAnswer();
            }
        });
    }

    submitAnswerBtn.onclick = () => {
      submitAnswer();
  };

  function generateMultiplication2() {
    type = "multiplication2";
    document.getElementById("button-row").style.display = "none";
    answer = group * perGroup;
    answerInput.style.display = "block";
    answerInput.value = '';
    answerInput.focus();
  }

  function submitAnswer() {
    if (type == "multiplication2") {
      userAnswer = parseInt(answerInput.value, 10);
    }
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
    
    if (type == "multiplication1") {
      generateMultiplication2();
    } else {
      generateQuestion();
    }
    } else {
    if (!currentQuestionCounted) {
          totalQuestions += 1;
          currentQuestionCounted = true;
        }
    feedback.textContent = "Try again!";
    }

    currentQuestionCounted = false;
  }

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
        window.location.href = '/topics/36';
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
            topic_id: 36
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
  