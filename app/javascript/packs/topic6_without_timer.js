import { drawNumberBond } from './number_bond_builder.js';

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

    // First part of the question when carrying involved 
        // sample for this step: 28 + 4 , circle would be 4 as whole, 2 and 2 as parts, this step solves for the circle
        function generateQuestion() {
            twoDigitNumber = Math.floor(Math.random() * 90) + 10;
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
                <h2>${twoDigitNumber} + ${oneDigitNumber} = ${twoDigitNumber} + ${leftCircleNumber} + ${rightCircleNumber}</h2>
                <div class="number-bond">
                <div class="circle" id="total">?</div>
                <div class="circle" id="left">?</div>
                <div class="circle" id="right">?</div>
                <canvas class="lines" id="gameCanvas">
                    <line id="line1" stroke="black" stroke-width="2" />
                    <line id="line2" stroke="black" stroke-width="2" />
                </canvas>
                </div>
                <h2 id="questionParts">PART 1 :   ${oneDigitNumber} - ${leftCircleNumber} = </h2>
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
                <h2>${twoDigitNumber} + ${oneDigitNumber} = ${previousMultipleOfTen} + ${rightCircleNumber} + ${oneDigitNumber}</h2>
                <div class="number-bond">
                <div class="circle" id="total">?</div>
                <div class="circle" id="left">?</div>
                <div class="circle" id="right">?</div>
                <canvas class="lines" id="gameCanvas">
                    <line id="line1" stroke="black" stroke-width="2" />
                    <line id="line2" stroke="black" stroke-width="2" />
                </canvas>
                </div>
                <h2 id="questionParts">PART 1 :   ${twoDigitNumber} - ${leftCircleNumber} = </h2>
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
      document.getElementById('right').textContent = rightCircleNumber;
        const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `PART 2 :   ${twoDigitNumber} + ${leftCircleNumber}`;
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
      document.getElementById('right').textContent = rightCircleNumber;
        const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `PART 2 :   ${rightCircleNumber} + ${oneDigitNumber}`;
        }
    
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
      const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `${newTotal} + ${rightCircleNumber}`;
        }
      answerPart3 = newTotal + rightCircleNumber;
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
        const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `SO...  ${twoDigitNumber} + ${oneDigitNumber} = `;
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
      const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `${previousMultipleOfTen} + ${answerPart2}`;
        }
      answerPart3 = previousMultipleOfTen + answerPart2;
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
            
            generateFinalQuestionB(twoDigitNumber, oneDigitNumber, answerPart3)
            } else {
            feedback.textContent = "Try again!";
            }
    
            currentQuestionCounted = false;
    
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
        const questionPartsHeading = document.getElementById('questionParts');
        if (questionPartsHeading) {
          questionPartsHeading.textContent = `SO..... ${twoDigitNumber} + ${oneDigitNumber} = `;
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
    
            currentQuestionCounted = false;
    
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
  