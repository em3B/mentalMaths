export function drawNumberBond(a, b, total, missing = 'a') {
    // Set the text content based on which value is missing
    document.querySelector('#left .number').textContent = missing === 'a' ? '?' : a;
    document.querySelector('#right .number').textContent = missing === 'b' ? '?' : b;
    document.querySelector('#total .number').textContent = missing === 'total' ? '?' : total;

    const gameContainer = document.getElementById("game-container");

    // Ensure the container is positioned (relative or absolute) for correct calculation of positions
    gameContainer.style.position = 'relative';

    // Function to get the center of an element
    const getCenter = (el) => {
        return {
          x: el.offsetLeft + el.offsetWidth / 2,
          y: el.offsetTop + el.offsetHeight / 2
        };
      };       

    const leftCircle = document.querySelector('#left.circle')
    const rightCircle = document.querySelector('#right.circle')
    const totalCircle = document.querySelector('#total.circle')

    requestAnimationFrame(() => {
        const p1 = getCenter(leftCircle);
        const p2 = getCenter(rightCircle);
        const p3x = (leftCircle.offsetLeft + rightCircle.offsetLeft + rightCircle.offsetWidth) / 2;
        const p3y = totalCircle.offsetTop + totalCircle.offsetHeight;
    
        const canvas = document.getElementById('gameCanvas');
        const rect = canvas.getBoundingClientRect();
        canvas.width = rect.width;
        canvas.height = rect.height;
        const ctx = canvas.getContext('2d');
    
        ctx.clearRect(0, 0, canvas.width, canvas.height);
    
        // Draw lines
        ctx.beginPath();
        ctx.moveTo(p1.x, p1.y);
        ctx.lineTo(p3x, p3y);
        ctx.stroke();
    
        ctx.beginPath();
        ctx.moveTo(p2.x, p2.y);
        ctx.lineTo(p3x, p3y);
        ctx.stroke();
    });
     
}
