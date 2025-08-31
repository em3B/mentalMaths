import { drawNumberBond } from './number_bond_builder.js';
import { wiggleCircle } from './circle_wiggler.js';
import { stopWiggle } from './circle_wiggler.js';

(function runGame() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let totalQuestions = 0; 
    let correctAnswers = 0;
    let answerPart1 = 0;
    let answerPart2 = 0;
    let answerPart3 = 0;
    let twoDigitNumber = 0;
    let oneDigitNumber = 0;
    let previousMultipleOfTen = 0;
    let leftCircleNumber = 0;
    let rightCircleNumber = 0;
    let submitClickHandler;
    let currentQuestionCounted = false;
    let tickLeft;
    let tickRight;
    let leftCircle;
    let rightCircle;
    let firstPart;
    let secondPart;
    let replacement1;
    let replacement2;
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
            <div id="question-text"></div>
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
    const questionText = document.getElementById("question-text");
    const answerInput = document.getElementById("answer-input");
    const submitAnswerBtn = document.getElementById("submit-answer-btn");
    const feedback = document.getElementById("feedback");
    const timerDisplay = document.getElementById("timer");
    const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");

    answerInput.onkeydown = (event) => {
      if (event.key === 'Enter') submitAnswerBtn.click();
    };

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

    function showTick(partId) {
      requestAnimationFrame(() => {
        tickLeft = document.getElementById("tick-left");
        tickRight = document.getElementById("tick-right");

        if (partId.toLowerCase() == 'left') {
          tickLeft.classList.remove('hidden');
        } else if (partId.toLowerCase() == 'right') {
          tickRight.classList.remove('hidden');
        } else {
          console.log("Tick not found yet!");
        }
    })
  }

    // sample for this step: 28 x 4 , circle would be 28 as whole, 20 and 8 as parts, this step solves for the circle
    function generateQuestion() {
      // should be a two digit number that is not a multiple of 10 
        do {
          twoDigitNumber = Math.floor(Math.random() * 90) + 10; // 10–99
        } while (twoDigitNumber % 10 === 0); // Retry if it's a multiple of 10
        oneDigitNumber = Math.floor(Math.random() * 8) + 1;
        previousMultipleOfTen = Math.floor(twoDigitNumber / 10) * 10;
        leftCircleNumber = previousMultipleOfTen;
        rightCircleNumber = twoDigitNumber - leftCircleNumber;
    
        // ✅ Set innerHTML first
        questionText.innerHTML = `
            <h1 id="main-question"></h1>
            <div class="number-bond">
            <div class="circle" id="total">
              <div class="circle-content">
                <span class="number">?</span>
                <span class="total tick hidden" id="tick-total">
                  <img src="https://res.cloudinary.com/dm37aktki/image/upload/v1747555519/MentalMaths/tick_mark_jepedz.png" alt="tick" width="24" />
                </span>
              </div>
            </div>
            <div class="circle" id="right">
              <div class="circle-content">
                <span class="number">?</span>
                <div class="right tick hidden" id="tick-right">
                  <img src="https://res.cloudinary.com/dm37aktki/image/upload/v1747555519/MentalMaths/tick_mark_jepedz.png" alt="tick" width="24" />
                </div>
              </div>
            </div>
            <div class="circle" id="left">
              <div class="circle-content">
                <span class="number">?</span>
                <div class="left tick hidden" id="tick-left">
                  <img src="https://res.cloudinary.com/dm37aktki/image/upload/v1747555519/MentalMaths/tick_mark_jepedz.png" alt="tick" width="24" />
                </div>
              </div>
            </div>
            <canvas class="lines" id="gameCanvas" width="300" height="200">
                <line id="line1" />
                <line id="line2" />
            </canvas>
            </div>
            <h2 id="questionParts"></h2>
        `;

        tickLeft = document.getElementById("tick-left");
        tickRight = document.getElementById("tick-right");
    
        // ✅ Then draw the number bond
        // ✅ Wait for layout to stabilize
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
              setTimeout(() => {
                drawNumberBond(leftCircleNumber, rightCircleNumber, leftCircleNumber + rightCircleNumber, 'b');
              }, 0);
            });
          }); 
    
        answerPart1 = rightCircleNumber;
        answerInput.value = '';
        answerInput.focus();

         // Remove previous handlers, if they exist
        if (submitClickHandler) {
          submitAnswerBtn.removeEventListener('click', submitClickHandler);
        }

        rightCircle = document.querySelector('#right.circle');
        wiggleCircle(rightCircle);

        submitClickHandler = () => {

          tickLeft = document.getElementById("tick-left");
          tickRight = document.getElementById("tick-right");
        
          const userAnswer = parseInt(answerInput.value, 10);
          if (userAnswer === answerPart1) {
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

          stopWiggle();

          document.getElementById("main-question").textContent = `${twoDigitNumber} x ${oneDigitNumber} ➡️✨ (${leftCircleNumber} x ${oneDigitNumber}) + ( ${rightCircleNumber} x ${oneDigitNumber} )`;
          
          generateQuestionPart2();
          } else {
          if (!currentQuestionCounted) {
            totalQuestions += 1;
            currentQuestionCounted = true;
          }
          feedback.textContent = "Try again!";
          }
        }

        currentQuestionCounted = false;

        // Attach new handlers
    submitAnswerBtn.onclick = submitClickHandler;
  };  


  // sample for this step: 28 x 4, this step does 20 x 4
 function generateQuestionPart2() {
  document.querySelector('#right .number').textContent = rightCircleNumber;

    // generate innerHTML for the main question up top, allowing for js styling
  document.getElementById("main-question").innerHTML = `${twoDigitNumber} x ${oneDigitNumber} ➡️✨ 
  <span class="highlight-wrapper">
    <span class="replacement-value hidden" id="replacement-value"></span>
    <span class="first-part">${leftCircleNumber} x ${oneDigitNumber}</span> 
    <span class="replacement-value-2 hidden" id="replacement-value-2"></span>
    <span class="second-part">+ ( ${rightCircleNumber} x ${oneDigitNumber} )</span>
  </span>`;

  // add highlighted box to the first part 
  firstPart = document.querySelector(".first-part");
  firstPart.classList.add("highlighted-part");

    const questionPartsHeading = document.getElementById('questionParts');
    if (questionPartsHeading) {
      questionPartsHeading.textContent = `FIRST........ ${leftCircleNumber} x ${oneDigitNumber} =`;
    }
    answerPart2 = leftCircleNumber * oneDigitNumber;
    answerInput.value = '';
    answerInput.focus();

      // Remove previous handlers, if they exist
    if (submitClickHandler) {
      submitAnswerBtn.removeEventListener('click', submitClickHandler);
    }

    leftCircle = document.querySelector('#left.circle');
    wiggleCircle(leftCircle);

        submitClickHandler = () => {
          const userAnswer = parseInt(answerInput.value, 10);
          if (userAnswer === answerPart2) {
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

          tickLeft = document.getElementById("tick-left");
          tickRight = document.getElementById("tick-right");
          
          stopWiggle();
          showTick("left");
          generateQuestionPart3();
          } else {
          if (!currentQuestionCounted) {
            totalQuestions += 1;
            currentQuestionCounted = true;
          }
          feedback.textContent = "Try again!";
          }
        }

        currentQuestionCounted = false;

      // Attach new handlers
      submitAnswerBtn.onclick = submitClickHandler;
 }


// sample : 28 + 4 , this step does 8 x 4
 function generateQuestionPart3() {
    // remove highlighted first part and show its answer, highlight second part 
  firstPart = document.querySelector(".first-part");
  secondPart = document.querySelector(".second-part");
  replacement1 = document.getElementById("replacement-value");
  firstPart.style.backgroundColor = "transparent";
  firstPart.style.border = "none";
  firstPart.classList.add("answered");
  replacement1.textContent = answerPart2;
  replacement1.classList.remove("hidden");
  secondPart.classList.add("highlighted-part");

  const questionPartsHeading = document.getElementById('questionParts');
    if (questionPartsHeading) {
      questionPartsHeading.textContent = `NEXT......... ${rightCircleNumber} x ${oneDigitNumber} =`;
    }
  answerPart3 = rightCircleNumber * oneDigitNumber;
  answerInput.value = '';
  answerInput.focus();

    // Remove previous handlers, if they exist
  if (submitClickHandler) {
    submitAnswerBtn.removeEventListener('click', submitClickHandler);
  }

  rightCircle = document.querySelector('#right.circle');
  wiggleCircle(rightCircle);

      submitClickHandler = () => {
        const userAnswer = parseInt(answerInput.value, 10);
        if (userAnswer === answerPart3) {
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

        stopWiggle();
        showTick("right");
        
        generateFinalPart();
        } else {
        if (!currentQuestionCounted) {
          totalQuestions += 1;
          currentQuestionCounted = true;
        }

        feedback.textContent = "Try again!";
        }

        currentQuestionCounted = false;

  // Attach new handlers
    submitAnswerBtn.onclick = submitClickHandler;
 }


  // Attach new handlers
    submitAnswerBtn.onclick = submitClickHandler;
}

// in 28 x 4, this does 32 + 80
function generateFinalPart() {
      // remove highlighted first part and show its answer, highlight second part 
    secondPart = document.querySelector(".second-part");
    replacement2 = document.getElementById("replacement-value-2");
    secondPart.style.backgroundColor = "transparent";
    secondPart.style.border = "none";
    secondPart.classList.add("answered");
    replacement2.textContent = answerPart3;
    replacement2.classList.remove("hidden");

    const questionPartsHeading = document.getElementById('questionParts');
    if (questionPartsHeading) {
      questionPartsHeading.textContent = `SO......  ${answerPart2} + ${answerPart3} = `;
    }
  answerInput.value = '';
  answerInput.focus();

    // Remove previous handlers, if they exist
  if (submitClickHandler) {
    submitAnswerBtn.removeEventListener('click', submitClickHandler);
  }

      submitClickHandler = () => {
        const userAnswer = parseInt(answerInput.value, 10);
        if (userAnswer === answerPart2 + answerPart3) {
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
        
        generateQuestion();
        } else {
        if (!currentQuestionCounted) {
          totalQuestions += 1;
          currentQuestionCounted = true;
        }

        feedback.textContent = "Try again!";
        }

        currentQuestionCounted = false;
 }

    // Attach new handlers
    submitAnswerBtn.onclick = submitClickHandler;
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
        window.location.href = '/topics/29';
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
            topic_id: 29
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
  