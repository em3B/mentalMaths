import { drawNumberBond } from './number_bond_builder.js';
import { wiggleCircle } from './circle_wiggler.js';
import { stopWiggle } from './circle_wiggler.js';

(function runGame() {
    const gameContainer = document.getElementById('game-container');
    let answerPart1 = 0;
    let answerPart2 = 0;
    let answerPart3 = 0;
    let twoDigitNumber = 0;
    let oneDigitNumber = 0;
    let nextMultipleOfTen = 0;
    let previousMultipleOfTen = 0;
    let leftCircleNumber = 0;
    let rightCircleNumber = 0;
    let sumLessThanNextMultipleOfTen = true;
    let submitClickHandler;
    let submitKeyHandler;
    let tickLeft;
    let tickRight;
    let leftCircle;
    let rightCircle;
    let firstPart;
    let secondPart;
    let replacement;
  
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
    const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");
    const endGameBtn = document.getElementById("go-to-topic-index");

    // Hide setup, show game
    questionSection.style.display = "block";
    generateQuestion();

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
        // sample for this step: 28 + 4 , circle would be 4 as whole, 2 and 2 as parts, this step solves for the circle
        function generateQuestion() {
          // should be a two digit number that is not a multiple of 10 
            do {
              twoDigitNumber = Math.floor(Math.random() * 90) + 10; // 10–99
            } while (twoDigitNumber % 10 === 0); // Retry if it's a multiple of 10
            oneDigitNumber = Math.floor(Math.random() * 8) + 1;
            nextMultipleOfTen = Math.ceil(twoDigitNumber / 10) * 10; 
            sumLessThanNextMultipleOfTen = (twoDigitNumber + oneDigitNumber) < nextMultipleOfTen;
            if (sumLessThanNextMultipleOfTen) {
              generateQuestionB(twoDigitNumber, oneDigitNumber);
            } else {
            leftCircleNumber = nextMultipleOfTen - twoDigitNumber;
            rightCircleNumber = oneDigitNumber - leftCircleNumber;
        
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
                    <span class="right tick hidden" id="tick-right">
                      <img src="https://res.cloudinary.com/dm37aktki/image/upload/v1747555519/MentalMaths/tick_mark_jepedz.png" alt="tick" width="24" />
                    </span>
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
            if (submitKeyHandler) {
              answerInput.removeEventListener('keydown', submitKeyHandler);
            }
    
            submitClickHandler = () => {
              const userAnswer = parseInt(answerInput.value, 10);
              if (userAnswer === answerPart1) {
              feedback.textContent = "Correct!";

              stopWiggle();

              tickLeft = document.getElementById("tick-left");
              tickRight = document.getElementById("tick-right");
              
              confetti({
                particleCount: 150,
                spread: 70,
                origin: { y: 0.6 }
              });
    
              const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
              tada.play();

              document.getElementById("main-question").textContent = `${twoDigitNumber} + ${oneDigitNumber} ➡️✨ ${twoDigitNumber} + ${leftCircleNumber} + ${rightCircleNumber}`;
              
              generateQuestionPart2(twoDigitNumber, oneDigitNumber, leftCircleNumber, rightCircleNumber);
              } else {
              feedback.textContent = "Try again!";
              }
            }
    
          submitKeyHandler = (event) => {
          if (event.key === 'Enter') {
            submitAnswerBtn.click();
          }
        };  
            }
    
            // Attach new handlers
        submitAnswerBtn.onclick = submitClickHandler;
        answerInput.onkeydown = submitKeyHandler;
      };  
    
      // question path when no carrying involved 
      // sample is 21 + 3, circle is whole of 21 with 20 and 1 as parts, this step sets up the circle 
      function generateQuestionB(twoDigitNumber, oneDigitNumber) {
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
            if (submitKeyHandler) {
              answerInput.removeEventListener('keydown', submitKeyHandler);
            }
    
            submitClickHandler = () => {
              const userAnswer = parseInt(answerInput.value, 10);
              if (userAnswer === answerPart1) {
              feedback.textContent = "Correct!";
              
              confetti({
                particleCount: 150,
                spread: 70,
                origin: { y: 0.6 }
              });
    
              const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
              tada.play();

              stopWiggle();

              document.getElementById("main-question").textContent = `${twoDigitNumber} + ${oneDigitNumber}    ➡️✨   ${previousMultipleOfTen} + ${rightCircleNumber} + ${oneDigitNumber}`;
              
              generateQuestionPart2b(twoDigitNumber, oneDigitNumber, leftCircleNumber, rightCircleNumber, previousMultipleOfTen);
              } else {
              feedback.textContent = "Try again!";
              }
            }
    
          submitKeyHandler = (event) => {
          if (event.key === 'Enter') {
            submitAnswerBtn.click();
          }
        };  
    
          // Attach new handlers
          submitAnswerBtn.onclick = submitClickHandler;
          answerInput.onkeydown = submitKeyHandler;
      }
    
      //  question path when carrying over involved
      // sample for this step: 28 + 4, this step does 28 + 2 
     function generateQuestionPart2(twoDigitNumber, oneDigitNumber, leftCircleNumber, rightCircleNumber) {
      document.querySelector('#right .number').textContent = rightCircleNumber;

      // generate innerHTML for the main question up top, allowing for js styling
      document.getElementById("main-question").innerHTML = `${twoDigitNumber} + ${oneDigitNumber} ➡️✨ 
      <span class="highlight-wrapper">
        <span class="replacement-value hidden" id="replacement-value"></span>
        <span class="first-part">${twoDigitNumber} + ${leftCircleNumber}</span> 
        <span class="second-part">+ ${rightCircleNumber}</span>
      </span>`;

      // add highlighted box to the first part 
      firstPart = document.querySelector(".first-part");
      firstPart.classList.add("highlighted-part");

        const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `FIRST........ ${twoDigitNumber} + ${leftCircleNumber} = `;
        }
        answerPart2 = twoDigitNumber + leftCircleNumber;
        answerInput.value = '';
        answerInput.focus();
    
          // Remove previous handlers, if they exist
        if (submitClickHandler) {
          submitAnswerBtn.removeEventListener('click', submitClickHandler);
        }
        if (submitKeyHandler) {
          answerInput.removeEventListener('keydown', submitKeyHandler);
        }

        leftCircle = document.querySelector('#left.circle');
        wiggleCircle(leftCircle);
    
            submitClickHandler = () => {
              const userAnswer = parseInt(answerInput.value, 10);
              if (userAnswer === answerPart2) {
              feedback.textContent = "Correct!";
              
              confetti({
                particleCount: 150,
                spread: 70,
                origin: { y: 0.6 }
              });
    
              const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
              tada.play();

              tickLeft = document.getElementById("tick-left");
              tickRight = document.getElementById("tick-right");

              stopWiggle();
              showTick("left");
              
              generateQuestionPart3(answerPart2, rightCircleNumber);
              } else {
              feedback.textContent = "Try again!";
              }
            }
    
          submitKeyHandler = (event) => {
          if (event.key === 'Enter') {
            submitAnswerBtn.click();
          }
        }; 
    
          // Attach new handlers
          submitAnswerBtn.onclick = submitClickHandler;
          answerInput.onkeydown = submitKeyHandler;
     }
    
    //  question path when no carrying over involved
    // sample: 21 + 3, this step does 1 + 3
     function generateQuestionPart2b(twoDigitNumber, oneDigitNumber, leftCircleNumber, rightCircleNumber, previousMultipleOfTen) {
      document.querySelector('#right .number').textContent = rightCircleNumber;

      // generate innerHTML for the main question up top, allowing for js styling
      document.getElementById("main-question").innerHTML = `${twoDigitNumber} + ${oneDigitNumber} ➡️✨ 
      <span class="highlight-wrapper">
        <span class="second-part">${previousMultipleOfTen} +</span> 
        <span class="replacement-value hidden" id="replacement-value"></span>
        <span class="first-part">${rightCircleNumber} + ${oneDigitNumber}</span>
      </span>`;

      // add highlighted box to the first part 
      firstPart = document.querySelector(".first-part");
      firstPart.classList.add("highlighted-part");
      
        const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `FIRST....... ${rightCircleNumber} + ${oneDigitNumber} =`;
        }

        rightCircle = document.querySelector('#right.circle');
        wiggleCircle(rightCircle);
    
        answerPart2 = rightCircleNumber + oneDigitNumber;
        answerInput.value = '';
        answerInput.focus();
    
          // Remove previous handlers, if they exist
        if (submitClickHandler) {
          submitAnswerBtn.removeEventListener('click', submitClickHandler);
        }
        if (submitKeyHandler) {
          answerInput.removeEventListener('keydown', submitKeyHandler);
        }
    
            submitClickHandler = () => {
              const userAnswer = parseInt(answerInput.value, 10);
              if (userAnswer === answerPart2) {
              feedback.textContent = "Correct!";
              
              confetti({
                particleCount: 150,
                spread: 70,
                origin: { y: 0.6 }
              });
    
              const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
              tada.play();

              stopWiggle();
              showTick("right");
              
              generateQuestionPart3b(answerPart2, previousMultipleOfTen);
              } else {
              feedback.textContent = "Try again!";
              }
            }
    
          submitKeyHandler = (event) => {
          if (event.key === 'Enter') {
            submitAnswerBtn.click();
          }
        }; 
    
          // Attach new handlers
        submitAnswerBtn.onclick = submitClickHandler;
        answerInput.onkeydown = submitKeyHandler;
     }
    
    // question path when carrying involved
    // sample : 28 + 4 , this step does 30 + 2
     function generateQuestionPart3(newTotal, rightCircleNumber) {
      // remove highlighted first part and show its answer, highlight second part 
      firstPart = document.querySelector(".first-part");
      secondPart = document.querySelector(".second-part");
      replacement = document.getElementById("replacement-value");
      firstPart.style.backgroundColor = "transparent";
      firstPart.style.border = "none";
      firstPart.classList.add("answered");
      replacement.textContent = newTotal;
      replacement.classList.remove("hidden");
      secondPart.classList.add("highlighted-part");
      const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `NEXT......... ${newTotal} + ${rightCircleNumber} =`;
        }
      answerPart3 = newTotal + rightCircleNumber;
      answerInput.value = '';
      answerInput.focus();

      rightCircle = document.querySelector('#right.circle');
      wiggleCircle(rightCircle);
    
        // Remove previous handlers, if they exist
      if (submitClickHandler) {
        submitAnswerBtn.removeEventListener('click', submitClickHandler);
      }
      if (submitKeyHandler) {
        answerInput.removeEventListener('keydown', submitKeyHandler);
      }
    
          submitClickHandler = () => {
            const userAnswer = parseInt(answerInput.value, 10);
            if (userAnswer === answerPart3) {
            feedback.textContent = "Correct!";
            
            confetti({
              particleCount: 150,
              spread: 70,
              origin: { y: 0.6 }
            });
    
            const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
            tada.play();

            stopWiggle();
            showTick("right");
            
            generateFinalPart(twoDigitNumber, oneDigitNumber, answerPart3);
            } else {    
            feedback.textContent = "Try again!";
            }
    
        submitKeyHandler = (event) => {
        if (event.key === 'Enter') {
          submitAnswerBtn.click();
        }
      }; 
    
      // Attach new handlers
        submitAnswerBtn.onclick = submitClickHandler;
        answerInput.onkeydown = submitKeyHandler;
     }
    
    
      // Attach new handlers
        submitAnswerBtn.onclick = submitClickHandler;
        answerInput.onkeydown = submitKeyHandler;
    }
    
    // for question path with carrying 
    function generateFinalPart(twoDigitNumber, oneDigitNumber, answerPart3) {
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
          questionPartsHeading.textContent = `SO......  ${twoDigitNumber} + ${oneDigitNumber} = `;
        }
      answerInput.value = '';
      answerInput.focus();
    
        // Remove previous handlers, if they exist
      if (submitClickHandler) {
        submitAnswerBtn.removeEventListener('click', submitClickHandler);
      }
      if (submitKeyHandler) {
        answerInput.removeEventListener('keydown', submitKeyHandler);
      }
    
          submitClickHandler = () => {
            const userAnswer = parseInt(answerInput.value, 10);
            if (userAnswer === answerPart3) {
            feedback.textContent = "Correct!";
            
            confetti({
              particleCount: 150,
              spread: 70,
              origin: { y: 0.6 }
            });
    
            const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
            tada.play();
            
            generateQuestion();
            } else {
    
            feedback.textContent = "Try again!";
            }
    
        submitKeyHandler = (event) => {
        if (event.key === 'Enter') {
          submitAnswerBtn.click();
        }
      }; 
     }
    
        // Attach new handlers
        submitAnswerBtn.onclick = submitClickHandler;
        answerInput.onkeydown = submitKeyHandler;
    }
    
    //  question path when no carrying involved
    function generateQuestionPart3b(answerPart2, previousMultipleOfTen) {
      // remove highlighted first part and show its answer, highlight second part 
      firstPart = document.querySelector(".first-part");
      secondPart = document.querySelector(".second-part");
      replacement = document.getElementById("replacement-value");
      firstPart.style.backgroundColor = "transparent";
      firstPart.style.border = "none";
      firstPart.classList.add("answered");
      replacement.textContent = answerPart2;
      replacement.classList.remove("hidden");
      secondPart.classList.add("highlighted-part");

      const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `NEXT......... ${previousMultipleOfTen} + ${answerPart2} =`;
        }
      answerPart3 = previousMultipleOfTen + answerPart2;
      answerInput.value = '';
      answerInput.focus();

      leftCircle = document.querySelector('#left.circle');
      wiggleCircle(leftCircle);
    
        // Remove previous handlers, if they exist
      if (submitClickHandler) {
        submitAnswerBtn.removeEventListener('click', submitClickHandler);
      }
      if (submitKeyHandler) {
        answerInput.removeEventListener('keydown', submitKeyHandler);
      }
    
          submitClickHandler = () => {
            const userAnswer = parseInt(answerInput.value, 10);
            if (userAnswer === answerPart3) {
            feedback.textContent = "Correct!";
            
            confetti({
              particleCount: 150,
              spread: 70,
              origin: { y: 0.6 }
            });
    
            const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
            tada.play();

            stopWiggle();
            showTick("left");
            
            generateFinalQuestionB(twoDigitNumber, oneDigitNumber, answerPart3)
            } else {
            feedback.textContent = "Try again!";
            }
    
        submitKeyHandler = (event) => {
        if (event.key === 'Enter') {
          submitAnswerBtn.click();
        }
      }; 
    }
        // Attach new handlers
        submitAnswerBtn.onclick = submitClickHandler;
        answerInput.onkeydown = submitKeyHandler;
     }
    
     // for question path without carrying 
    function generateFinalQuestionB(twoDigitNumber, oneDigitNumber, answerPart3) {
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
          questionPartsHeading.textContent = `SO....... ${twoDigitNumber} + ${oneDigitNumber} = `;
        }
      answerInput.value = '';
      answerInput.focus();
    
        // Remove previous handlers, if they exist
      if (submitClickHandler) {
        submitAnswerBtn.removeEventListener('click', submitClickHandler);
      }
      if (submitKeyHandler) {
        answerInput.removeEventListener('keydown', submitKeyHandler);
      }
    
          submitClickHandler = () => {
            const userAnswer = parseInt(answerInput.value, 10);
            if (userAnswer === answerPart3) {
            feedback.textContent = "Correct!";
            
            confetti({
              particleCount: 150,
              spread: 70,
              origin: { y: 0.6 }
            });
    
            const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
            tada.play();
            
            generateQuestion();
            } else {
            feedback.textContent = "Try again!";
            }
    
        submitKeyHandler = (event) => {
        if (event.key === 'Enter') {
          submitAnswerBtn.click();
        }
      }; 
    
      // Attach new handlers
        submitAnswerBtn.onclick = submitClickHandler;
        answerInput.onkeydown = submitKeyHandler;
     }
    
        // Attach new handlers
        submitAnswerBtn.onclick = submitClickHandler;
        answerInput.onkeydown = submitKeyHandler;
    
    }
  
    endGameBtn.onclick = () => {
      window.location.href = '/topics/6';
    }
  
  })();
  