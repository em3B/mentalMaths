(function runGame() {
  const gameContainer = document.getElementById('game-container');

  if (!gameContainer) {
    console.error("Game container not found");
    return;
  }

  // Clear any existing content
  gameContainer.innerHTML = '';
  gameContainer.style.display = "block";

  // Add game content
  const gameContent = document.createElement('div');
  gameContent.innerHTML = `
    <p>Game has started! You have <span id="timer">60</span> seconds.</p>
    <div id="game-content">[Game logic goes here]</div>
  `;
  gameContainer.appendChild(gameContent);

  // Timer logic
  let timeLeft = 60;
  const timerDisplay = document.getElementById('timer');
  const timerInterval = setInterval(() => {
    timeLeft--;
    timerDisplay.textContent = timeLeft;

    if (timeLeft <= 0) {
      clearInterval(timerInterval);
      endGame();
    }
  }, 1000);

  function endGame() {
    const gameContent = document.getElementById('game-content');
    gameContent.innerHTML = `<strong>Time's up!</strong>`;
  }
})();
