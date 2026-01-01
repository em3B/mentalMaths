import { NumberBlocksHelper } from "./number_blocks_helper.js";

export function runTopic38WithoutTimer() {
    const gameContainer = document.getElementById('game-container');
    const userSignedIn = gameContainer.dataset.userSignedIn == "true";
    let answer = 0;
    let userAnswer = 0;
    let firstPart = 0;
    let secondPart = 0;
    let controller = null; 
    const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
  
    if (!gameContainer) {
        console.error("Game container not found");
        return;
    }

    gameContainer.innerHTML = '';
    gameContainer.style.display = "block";

    const gameContent = document.createElement('div');
    gameContent.innerHTML = `
    <div class="devise-form form-table">
        <div class="form-table">
        <div id="question-section">
            <h2 id="question-text"></h2>
            <div id="bar-model-container"></div>
            <label for="answer-input" class="visually-hidden">Answer to the maths question</label>
            <input type="number" id="answer-input" style="display: none;" />
            <button class="devise-btn" id="submit-answer-btn">Next</button>
            <h4 id="feedback"></h4>
            <button class="devise-btn" id="go-to-topic-index">Return to Topic</button>
        </div>
        </div>
    </div>
    `;
    gameContainer.appendChild(gameContent);

    const questionSection = document.getElementById("question-section");
    const questionText = document.getElementById("question-text");
    const answerInput = document.getElementById("answer-input");
    const submitAnswerBtn = document.getElementById("submit-answer-btn");
    const feedback = document.getElementById("feedback");
    const returnToTopicIndexBtn = document.getElementById("go-to-topic-index");
    const modelContainer = document.getElementById("bar-model-container");

    questionSection.style.display = "block";
    answerInput.style.display = "block"; 
    submitAnswerBtn.style.display = "block";

    // attach global event listeners once
    submitAnswerBtn.addEventListener("click", submitAnswer);
    answerInput.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            submitAnswer();
        }
    });
    returnToTopicIndexBtn.addEventListener("click", () => {
        window.location.href = "/topics/38";
    });

    // start game
    generateQuestion();

    function generateQuestion() {
        // destroy previous controller if any
        if (controller) {
            controller.destroy();
            controller = null;
        }

        // generate random numbers safely
        firstPart = Math.floor(Math.random() * 89) + 11; // 11–99
        const nextMultipleOfTen = Math.ceil(firstPart / 10) * 10;

        // ensure secondPart always valid: at least 1, and keeps sum < nextMultipleOfTen
        const maxSecondPart = nextMultipleOfTen - firstPart - 1;
        secondPart = Math.floor(Math.random() * maxSecondPart) + 1;

        answer = firstPart + secondPart;
        questionText.innerHTML = `${firstPart} + ${secondPart} = `;
        answerInput.value = '';
        answerInput.focus();

        // create new controller
        controller = new NumberBlocksHelper("addition", firstPart, secondPart, modelContainer, handleComplete);
    }

    function handleComplete(isCorrect) {
        if (isCorrect) userAnswer = answer;
    }

    function submitAnswer() {
        userAnswer = parseInt(answerInput.value, 10);

        if (userAnswer === answer) {
            feedback.textContent = "Correct!";
            tada.currentTime = 0;
            tada.play();

            generateQuestion();
        } else {
            feedback.textContent = "Try again!";
        }
    }
}