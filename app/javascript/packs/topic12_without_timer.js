// Clear and populate the game container
const gameContainer = document.getElementById('game-container');
if (gameContainer) {
  gameContainer.innerHTML = ''; // Optional clear
  const gameElement = document.createElement('div');
  gameElement.innerText = "This is the game content for topic 12.";
  gameContainer.appendChild(gameElement);
}
