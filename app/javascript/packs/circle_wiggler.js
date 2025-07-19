let wigglingCircle = null;

export function wiggleCircle(circle) {
  stopWiggle(); // stop any previous one
  if (circle) {
    circle.classList.add("wiggle");
    wigglingCircle = circle;
  }
}

export function stopWiggle() {
  if (wigglingCircle) {
    wigglingCircle.classList.remove("wiggle");
    wigglingCircle = null;
  }
}