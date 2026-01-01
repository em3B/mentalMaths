import { drawNumberBond } from './number_bond_builder.js';
import { wiggleCircle } from './circle_wiggler.js';
import { stopWiggle } from './circle_wiggler.js';

(function runGame() {
    const gameContainer = document.getElementById('game-container');
    let totalQuestions = 0; 
    let correctAnswers = 0;
    let answerPart1 = 0;
    let answerPart2 = 0;
    let answerPart3 = 0;
    let wholeNumber = 0;
    let leftCircleNumber = 0;
    let rightCircleNumber = 0;
    let submitClickHandler = null;
    let leftCircle;
    let rightCircle;
    let firstPartA;
    let firstPartB;
    let secondPartA;
    let secondPartB;
    let questionParts;
    let mainInstructions;
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
  
    // Possible Inputs from innerHtml
    const questionSection = document.getElementById("question-section");
    const questionText = document.getElementById("question-text");
    const answerInput = document.getElementById("answer-input");
    const submitAnswerBtn = document.getElementById("submit-answer-btn");
    const feedback = document.getElementById("feedback");
    const endGameBtn = document.getElementById("go-to-topic-index");

    answerInput.onkeydown = (event) => {
      if (event.key === 'Enter') submitAnswerBtn.click();
    };

    // Hide setup, show game
    questionSection.style.display = "block";
    generateQuestion();


    // First part of the question which sets up the number bond
    // sample for this step:  whole of 9, part of 2, remaining would be 7
    function generateQuestion() {
        wholeNumber = Math.floor(Math.random() * 90) + 10;
        leftCircleNumber = Math.floor(Math.random() * (wholeNumber - 1)) + 1; 
        rightCircleNumber = wholeNumber - leftCircleNumber;
    
        // ✅ Set innerHTML first
        questionText.innerHTML = `
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
            <h2 class="main-instructions hidden">Solve for the "____"</h2>
        `;

        mainInstructions = document.querySelector(".main-instructions");
        questionParts = document.getElementById('questionParts');
    
        // ✅ Then draw the number bond
        // ✅ Wait for layout to stabilize
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
              setTimeout(() => {
                drawNumberBond(leftCircleNumber, rightCircleNumber, wholeNumber, 'b');
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

        submitClickHandler = handleSubmitPart1Click;

        submitAnswerBtn.addEventListener('click', submitClickHandler);
  };  

  // sample for this step: 9 with part 2, 2 + ____ = 9
 function generateQuestionPart2() {
    document.querySelector('#right .number').textContent = rightCircleNumber;

    // add highlighted box to the first part 
    firstPartA = document.getElementById("add-1");
    firstPartA.classList.add("highlighted-part");
    mainInstructions.classList.remove("hidden");

    answerPart2 = wholeNumber - leftCircleNumber;
    answerInput.value = '';
    answerInput.focus();

      // Remove previous handlers, if they exist
    if (submitClickHandler) {
      submitAnswerBtn.removeEventListener('click', submitClickHandler);
    }

    rightCircle = document.querySelector('#right.circle');
    wiggleCircle(rightCircle);

    submitClickHandler = handleSubmitPart2Click;

    submitAnswerBtn.addEventListener('click', submitClickHandler);
 }


// sample : 9 with part 2, this part does 7 + ____ = 9
 function generateQuestionPart3() {
    // remove highlighted first part and show its answer, highlight second part 
  firstPartA = document.getElementById("add-1");
  firstPartB = document.getElementById("add-2");
  firstPartA.style.backgroundColor = "transparent";
  firstPartA.style.border = "none";
  firstPartB.classList.add("highlighted-part");

  answerPart3 = wholeNumber - rightCircleNumber;
  answerInput.value = '';
  answerInput.focus();

    // Remove previous handlers, if they exist
  if (submitClickHandler) {
    submitAnswerBtn.removeEventListener('click', submitClickHandler);
  }

  leftCircle = document.querySelector('#left.circle');
  wiggleCircle(leftCircle);

  submitClickHandler = handleSubmitPart3Click;

  submitAnswerBtn.addEventListener('click', submitClickHandler);
}

// in 9 with part 2 this part is 9 -2 = ____
function generateFourthPart() {

        // remove highlighted first part and show its answer, highlight second part 
    firstPartB = document.getElementById("add-2");
    secondPartA = document.getElementById("minus-1");
    firstPartB.style.backgroundColor = "transparent";
    firstPartB.style.border = "none";
    secondPartA.classList.add("highlighted-part");
  answerInput.value = '';
  answerInput.focus();

    // Remove previous handlers, if they exist
  if (submitClickHandler) {
    submitAnswerBtn.removeEventListener('click', submitClickHandler);
  }

  submitClickHandler = handleSubmitPart4Click;

  submitAnswerBtn.addEventListener('click', submitClickHandler);
}

// in sample 9 with part 2, this part does 9 - 7 = ____
function generateFifthPart() {
        // remove highlighted first part and show its answer, highlight second part 
    secondPartB = document.getElementById("minus-2");
    secondPartA = document.getElementById("minus-1");
    secondPartA.style.backgroundColor = "transparent";
    secondPartA.style.border = "none";
    secondPartB.classList.add("highlighted-part");
    answerInput.value = '';
    answerInput.focus();

        // Remove previous handlers, if they exist
    if (submitClickHandler) {
        submitAnswerBtn.removeEventListener('click', submitClickHandler);
    }

    submitClickHandler = handleSubmitPart5Click;

    submitAnswerBtn.addEventListener('click', submitClickHandler);
} 

    answerInput.addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        submitAnswerBtn.click();
      }
    });

    function handleSubmitPart1Click() {
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

          questionParts.innerHTML = `
            <div class="fact-family">
                <div class="addition-facts">
                <span id="add-1">${leftCircleNumber} + ____ = ${wholeNumber}</span>
                <span id="add-2">${rightCircleNumber} + ____ = ${wholeNumber}</span>
                </div>
                <div class="subtraction-facts">
                <span id="minus-1">${wholeNumber} - ${leftCircleNumber} = ____</span>
                <span id="minus-2">${wholeNumber} - ${rightCircleNumber} = ____</span>
                </div>
            </div>
            `;
          
          generateQuestionPart2(leftCircleNumber, rightCircleNumber);
          } else {
          feedback.textContent = "Try again!";
          }
    }

    function handleSubmitPart2Click() {
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

          document.getElementById('add-1').textContent = `${leftCircleNumber} + ${rightCircleNumber} = ${wholeNumber}`;
          
          stopWiggle();
          generateQuestionPart3();
          } else {
          feedback.textContent = "Try again!";
          }
    }

    function handleSubmitPart3Click() {
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

        document.getElementById('add-2').textContent = `${rightCircleNumber} + ${leftCircleNumber} = ${wholeNumber}`;

        stopWiggle();
        
        generateFourthPart();
        } else {
        feedback.textContent = "Try again!";
        }
    }

    function handleSubmitPart4Click() {
        const userAnswer = parseInt(answerInput.value, 10);
        if (userAnswer === wholeNumber - leftCircleNumber) {
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

        document.getElementById('minus-1').textContent = `${wholeNumber} - ${leftCircleNumber} = ${rightCircleNumber}`;
        
        generateFifthPart();
        } else {
        feedback.textContent = "Try again!";
        }
    }

    function handleSubmitPart5Click() {
                  const userAnswer = parseInt(answerInput.value, 10);
            if (userAnswer === wholeNumber - rightCircleNumber) {
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

            document.getElementById('minus-2').textContent = `${wholeNumber} - ${rightCircleNumber} = ${leftCircleNumber}`;
            
            generateQuestion();
            } else {
            feedback.textContent = "Try again!";
            }
    }

    function handleSubmitKey(event) {
      if (event.key === 'Enter') {
        submitAnswerBtn.click();
      }
  }
  
    endGameBtn.onclick = () => {
      window.location.href = '/topics/27';
    }
  
  })();
  