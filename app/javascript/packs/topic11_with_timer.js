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
    let answerPart4 = 0;
    let firstTwoDigitNumber = 0;
    let secondTwoDigitNumber = 0;
    let firstOnesPlaceDigit = 0;
    let secondOnesPlaceDigit = 0;
    let previousMultipleOfTen = 0;
    let previousMultipleOfTenSecondNumber = 0;
    let leftCircleNumber = 0;
    let rightCircleNumber = 0;
    let firstOnesGreaterThanOrEqualToSecond = true;
    let firstNumberIsMultipleOfTen = true;
    let submitClickHandler;
    let currentQuestionCounted = false;
    let tickLeft;
    let tickRight;
    let leftCircle;
    let rightCircle;
    let firstPart;
    let secondPart;
    let firstPartA;
    let firstPartB;
    let secondPartA;
    let secondPartB;
    let replacement;
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

    // First part of the question when carrying involved 
    // sample for this step: 52 - 34 , circle would be 4 as whole, 2 and 2 as parts, this step solves for the circle
    // main question = 52 - 30 - 2 - 2
    function generateQuestion() {
        firstTwoDigitNumber = Math.floor(Math.random() * 90) + 10;
        firstOnesPlaceDigit = firstTwoDigitNumber % 10;
                // should be a two digit number that is not a multiple of 10 
        do {
            secondTwoDigitNumber = Math.floor(Math.random() * 90) + 10; // 10–99
        } while (secondTwoDigitNumber % 10 === 0 || secondTwoDigitNumber > firstTwoDigitNumber || secondTwoDigitNumber === firstTwoDigitNumber); // Retry if it's a multiple of 10
        secondOnesPlaceDigit = secondTwoDigitNumber % 10;
        previousMultipleOfTenSecondNumber = secondTwoDigitNumber - secondOnesPlaceDigit;
        firstOnesGreaterThanOrEqualToSecond = firstOnesPlaceDigit >= secondOnesPlaceDigit;
        firstNumberIsMultipleOfTen = firstTwoDigitNumber % 10 === 0;
        if (firstOnesGreaterThanOrEqualToSecond || firstNumberIsMultipleOfTen) {
            generateQuestionB(firstTwoDigitNumber, secondTwoDigitNumber, previousMultipleOfTenSecondNumber);
        } else {
        leftCircleNumber = firstOnesPlaceDigit;
        rightCircleNumber = secondOnesPlaceDigit - leftCircleNumber;
    
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

          document.getElementById("main-question").textContent = `${firstTwoDigitNumber} - ${secondTwoDigitNumber}  ➡️✨ ${firstTwoDigitNumber} - ${previousMultipleOfTenSecondNumber} - ${leftCircleNumber} - ${rightCircleNumber}`;
          
          generateQuestionPart2(firstTwoDigitNumber, secondTwoDigitNumber, previousMultipleOfTenSecondNumber, leftCircleNumber, rightCircleNumber);
          } else {
          if (!currentQuestionCounted) {
            totalQuestions += 1;
            currentQuestionCounted = true;
          }
          feedback.textContent = "Try again!";
          }
        }

        currentQuestionCounted = false;
        }

        // Attach new handlers
    submitAnswerBtn.onclick = submitClickHandler;
  };  

  // question path when no carrying involved 
  // sample is 25 - 13, circle is whole of 13 with 10 and 3 as parts, this step sets up the circle 
  function generateQuestionB(firstTwoDigitNumber, secondTwoDigitNumber, previousMultipleOfTenSecondNumber) {
    leftCircleNumber = previousMultipleOfTenSecondNumber;
    rightCircleNumber = secondTwoDigitNumber - leftCircleNumber;

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
            <div class="circle" id="left">
              <div class="circle-content">
                <span class="number">?</span>
                <span class="left tick hidden" id="tick-left">
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
            <canvas class="lines" id="gameCanvas" width="300" height="200">
                <line id="line1" />
                <line id="line2" />
            </canvas>
            </div>
            <h2 id="questionParts"></h2>
        `;

    
        // ✅ Then draw the number bond
        // ✅ Wait for layout to stabilize
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
              setTimeout(() => {
                drawNumberBond(leftCircleNumber, rightCircleNumber, leftCircleNumber + rightCircleNumber, 'b');
              }, 0);
            });
          });    
          
        rightCircle = document.querySelector('#right.circle');
        wiggleCircle(rightCircle);
    
        answerPart1 = rightCircleNumber;
        answerInput.value = '';
        answerInput.focus();

                 // Remove previous handlers, if they exist
        if (submitClickHandler) {
          submitAnswerBtn.removeEventListener('click', submitClickHandler);
        }

        submitClickHandler = () => {
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

          document.getElementById("main-question").textContent = `${firstTwoDigitNumber} - ${secondTwoDigitNumber} ➡️✨ ${firstTwoDigitNumber} - ${previousMultipleOfTen} - ${rightCircleNumber}`;
          
          generateQuestionPart2b(firstTwoDigitNumber, secondTwoDigitNumber, leftCircleNumber, rightCircleNumber, previousMultipleOfTenSecondNumber);
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

  //  question path when carrying over involved
  // sample for this step: 52 - 34, this step does 52 - 2 
 function generateQuestionPart2(firstTwoDigitNumber, secondTwoDigitNumber, previousMultipleOfTenSecondNumber, leftCircleNumber, rightCircleNumber) {
  document.querySelector('#right .number').textContent = rightCircleNumber;

    // generate innerHTML for the main question up top, allowing for js styling
  document.getElementById("main-question").innerHTML = `${firstTwoDigitNumber} - ${secondTwoDigitNumber} ➡️✨ 
  <span class="highlight-wrapper">
    <span class="replacement-value hidden" id="replacement-value"></span>
    <span class="first-part-a">${firstTwoDigitNumber}</span> 
    <span class="replacement-value hidden" id="replacement-value"></span>
    <span class="second-part-b">- ${previousMultipleOfTenSecondNumber}</span>
    <span class="replacement-value hidden" id="replacement-value"></span>
    <span class="first-part-b">- ${leftCircleNumber}</span>
    <span class="replacement-value hidden" id="replacement-value"></span>
    <span class="second-part-a">- ${rightCircleNumber}</span>
  </span>`;

  // add highlighted box to the first part 
  firstPartA = document.querySelector(".first-part-a");
  firstPartA.classList.add("highlighted-part");
  firstPartB = document.querySelector(".first-part-b")
  firstPartB.classList.add("highlighted-part");

    const questionPartsHeading = document.getElementById('questionParts');
    if (questionPartsHeading) {
      questionPartsHeading.textContent = `FIRST........ ${firstTwoDigitNumber} - ${leftCircleNumber} =`;
    }
    answerPart2 = firstTwoDigitNumber - leftCircleNumber;
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
          generateQuestionPart3(answerPart2, rightCircleNumber, firstTwoDigitNumber, secondTwoDigitNumber);
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

//  question path when no carrying over involved
// sample: 25 - 13, this step does 25 - 3
 function generateQuestionPart2b(firstTwoDigitNumber, secondTwoDigitNumber, leftCircleNumber, rightCircleNumber, previousMultipleOfTenSecondNumber) {
  document.querySelector('#right .number').textContent = rightCircleNumber;

    // generate innerHTML for the main question up top, allowing for js styling
    document.getElementById("main-question").innerHTML = `${firstTwoDigitNumber} - ${secondTwoDigitNumber} ➡️✨ 
    <span class="highlight-wrapper">
      <span class="first-part">${firstTwoDigitNumber}</span> 
      <span class="replacement-value hidden" id="replacement-value"></span>
      <span class="second-part">- ${previousMultipleOfTenSecondNumber}</span>
      <span class="replacement-value hidden" id="replacement-value"></span>
      <span class="first-part-a">- ${rightCircleNumber}</span>
    </span>`;

    // add highlighted box to the first part 
    firstPart = document.querySelector(".first-part");
    firstPartA = document.querySelector(".first-part-a");
    firstPart.classList.add("highlighted-part");
    firstPartA.classList.add("highlighted-part");

    const questionPartsHeading = document.getElementById('questionParts');
    if (questionPartsHeading) {
      questionPartsHeading.textContent = `FIRST....... ${firstTwoDigitNumber} - ${rightCircleNumber} =`;
    }

    rightCircle = document.querySelector('#right.circle');
    wiggleCircle(rightCircle);

    answerPart2 = firstTwoDigitNumber - rightCircleNumber;
    answerInput.value = '';
    answerInput.focus();

      // Remove previous handlers, if they exist
    if (submitClickHandler) {
      submitAnswerBtn.removeEventListener('click', submitClickHandler);
    }

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

          stopWiggle();
          showTick("right");
          
          generateQuestionPart3b(answerPart2, previousMultipleOfTenSecondNumber);
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

// question path when carrying involved
// sample : 52 - 34 , this step does 50 - 2
 function generateQuestionPart3(newTotal, rightCircleNumber, firstTwoDigitNumber, secondTwoDigitNumber) {
    // remove highlighted first part and show its answer, highlight second part 
  firstPartA = document.querySelector(".first-part-a");
  firstPartB = document.querySelector(".first-part-b");
  secondPartA = document.querySelector(".second-part-a");
  replacement = document.getElementById("replacement-value");
  firstPartA.style.backgroundColor = "transparent";
  firstPartA.style.border = "none";
  firstPartA.classList.add("answered");
  firstPartB.style.backgroundColor = "transparent";
  firstPartB.classList.add("answered");
  firstPartB.style.border = "none";
  replacement.textContent = newTotal;
  replacement.classList.remove("hidden");
  secondPartA.classList.add("highlighted-part");

  const questionPartsHeading = document.getElementById('questionParts');
    if (questionPartsHeading) {
      questionPartsHeading.textContent = `NEXT......... ${newTotal} - ${rightCircleNumber} =`;
    }
  answerPart3 = newTotal - rightCircleNumber;
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
        
        generateFinalPart(answerPart3);
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

// for question path with carrying 
// sample : 52 - 34 , this step does 48 - 30
function generateFinalPart(answerPart3) {
            // remove highlighted first part and show its answer, highlight second part 
    secondPartA = document.querySelector(".second-part-a");
    secondPartB = document.querySelector(".second-part-b");
    replacement = document.getElementById("replacement-value");
    secondPartA.style.backgroundColor = "transparent";
    secondPartA.style.border = "none";
    secondPartA.classList.add("answered");
    replacement.textContent = answerPart3;
    replacement.classList.remove("hidden");
    secondPartB.classList.add("highlighted-part");

    const questionPartsHeading = document.getElementById('questionParts');
    if (questionPartsHeading) {
      questionPartsHeading.textContent = `LAST......  ${answerPart3} - ${previousMultipleOfTenSecondNumber} = `;
    }
  answerInput.value = '';
  answerInput.focus();

    // Remove previous handlers, if they exist
  if (submitClickHandler) {
    submitAnswerBtn.removeEventListener('click', submitClickHandler);
  }

  answerPart4 = answerPart3 - previousMultipleOfTenSecondNumber;

      submitClickHandler = () => {
        const userAnswer = parseInt(answerInput.value, 10);
        if (userAnswer === answerPart4) {
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

//  question path when no carrying involved
// sample: 25 - 13, this step does 22 - 10
function generateQuestionPart3b(answerPart2, previousMultipleOfTenSecondNumber) {
    // remove highlighted first part and show its answer, highlight second part 
  firstPart = document.querySelector(".first-part");
  firstPartA = document.querySelector(".first-part-a");
  secondPart = document.querySelector(".second-part");
  replacement = document.getElementById("replacement-value");
  firstPart.style.backgroundColor = "transparent";
  firstPart.style.border = "none";
  firstPart.classList.add("answered");
  firstPartA.style.backgroundColor = "transparent";
  firstPartA.style.border = "none";
  firstPartA.classList.add("answered");
  replacement.textContent = answerPart2;
  replacement.classList.remove("hidden");
  secondPart.classList.add("highlighted-part");

  const questionPartsHeading = document.getElementById('questionParts');
    if (questionPartsHeading) {
      questionPartsHeading.textContent = `NEXT......... ${answerPart2} - ${previousMultipleOfTenSecondNumber} =`;
    }
  answerPart3 = answerPart2 - previousMultipleOfTenSecondNumber;
  answerInput.value = '';
  answerInput.focus();

  leftCircle = document.querySelector('#left.circle');
  wiggleCircle(leftCircle);

    // Remove previous handlers, if they exist
  if (submitClickHandler) {
    submitAnswerBtn.removeEventListener('click', submitClickHandler);
  }

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
        showTick("left");
        
        generateFinalQuestionB(firstTwoDigitNumber, secondTwoDigitNumber, answerPart3)
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

 // for question path without carrying 
function generateFinalQuestionB(firstTwoDigitNumber, secondTwoDigitNumber, answerPart3) {
            // remove highlighted first part and show its answer, highlight second part 
    secondPart = document.querySelector(".second-part");
    replacement = document.getElementById("replacement-value");
    secondPart.style.backgroundColor = "transparent";
    secondPart.style.border = "none";
    secondPart.classList.add("answered");
    replacement.textContent = answerPart3;
    replacement.classList.remove("hidden");

    const questionPartsHeading = document.getElementById('questionParts');
    if (questionPartsHeading) {
      questionPartsHeading.textContent = `SO....... ${firstTwoDigitNumber} - ${secondTwoDigitNumber} = `;
    }
  answerInput.value = '';
  answerInput.focus();

    // Remove previous handlers, if they exist
  if (submitClickHandler) {
    submitAnswerBtn.removeEventListener('click', submitClickHandler);
  }

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
        
        generateQuestion();
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
        window.location.href = '/topics/11';
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
            topic_id: 11
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
  