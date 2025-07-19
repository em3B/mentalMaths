(function runGame() {
    const gameContainer = document.getElementById('game-container');
    let tenFrameValue = 0;
  
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
            <img id="question-image" src="" style="width: 300px; height: auto; object-fit: contain; visibility: hidden;">
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
    const questionImage = document.getElementById("question-image");
    const answerInput = document.getElementById("answer-input");
    const submitAnswerBtn = document.getElementById("submit-answer-btn");
    const feedback = document.getElementById("feedback");
    const endGameBtn = document.getElementById("go-to-topic-index");

    endGameBtn.onclick = () => {
        window.location.href = '/topics/9';
      }

    // Hide setup, show game
    questionSection.style.display = "block";
    generateQuestion();
  
  
    function generateQuestion() {
        // Generate image to use
        index = Math.floor(Math.random() * 10);
        tenFrameValue = displayTenFrameAndReturnValue(index) + 11;
        answerInput.value = '';
        answerInput.focus();
    }

    submitAnswerBtn.onclick = () => {
        const userAnswer = parseInt(answerInput.value, 10);
        if (userAnswer === tenFrameValue) {
        feedback.textContent = "Correct!";

        confetti({
          particleCount: 80,
          spread: 110,
          origin: { y: 0.6 }
        });

        const tada = new Audio('https://res.cloudinary.com/dm37aktki/video/upload/v1746467653/MentalMaths/tada-234709_oi9b9z.mp3');
        tada.play();
        
        // Hide image after 2 seconds, then load next question
        setTimeout(() => {
            questionImage.style.visibility = 'hidden';
            generateQuestion();
        }, 2000);
        } else {
        feedback.textContent = "Try again!";
        }
    };

    answerInput.addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        submitAnswerBtn.click();
      }
    });

    function displayTenFrameAndReturnValue(index) {
        // images to use
        const images = [
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466103/MentalMaths/frame11_b9agdp.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466103/MentalMaths/frame12_dqm6do.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466103/MentalMaths/frame13_z9dz9q.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466104/MentalMaths/frame14_d72cf7.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466104/MentalMaths/frame15_rw3pvl.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466104/MentalMaths/frame16_wvi1d6.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466109/MentalMaths/frame17_aaf8rz.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466109/MentalMaths/frame18_z1luxh.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466110/MentalMaths/frame19_i4rnu9.png",
            "https://res.cloudinary.com/dm37aktki/image/upload/v1746466564/MentalMaths/frame20_umjz0c.png"
        ]

        questionImage.src = images[index];
        questionImage.src = images[index];
        questionImage.style.visibility = 'visible';

        setTimeout(() => {
        questionImage.style.visibility = 'hidden';
        }, 2000);

        return index;
    }
  
    endGameBtn.onclick = () => {
      window.location.href = '/topics/9';
    }
  
  })();
  