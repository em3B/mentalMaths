export class NumberBlocksHelper {
constructor(type, firstNumber, secondNumber, container, onComplete = null, isRegroupingInvolved = false) {
  this.type = type;
  this.firstNumber = firstNumber;
  this.secondNumber = secondNumber;
  this.answer = (type === "addition")
    ? firstNumber + secondNumber
    : firstNumber - secondNumber;

  this.container = container;
  this.onComplete = onComplete;
  this.isRegroupingInvolved = isRegroupingInvolved; // ✅ NEW

  this.fixedBlocks = NumberBlocksHelper.decomposeNumber(firstNumber);

  if (this.type === "addition") {
    this.userBlocks = { hundreds: 0, tens: 0, ones: 0 };
  } else if (this.type === "subtraction") {
    this.struck = {
      hundreds: Array(this.fixedBlocks.hundreds).fill(false),
      tens: Array(this.fixedBlocks.tens).fill(false),
      ones: Array(this.fixedBlocks.ones).fill(false),
    };
  }

  this.render();
}

  // Break number into blocks
  static decomposeNumber(num) {
    return {
      hundreds: Math.floor(num / 100),
      tens: Math.floor((num % 100) / 10),
      ones: num % 10
    };
  }

  // --- Interactions ---
  addBlock(type) {
    if (this.type !== "addition") return;
    this.userBlocks[type]++;
    this.render();
  }

  removeBlock(type) {
    if (this.type !== "addition") return;
    if (this.userBlocks[type] > 0) {
      this.userBlocks[type]--;
      this.render();
    }
  }

toggleStrike(type, index) {
  if (this.type !== "subtraction") return;

  const key = this.getStrikeKey(type); 
  this.struck[key][index] = !this.struck[key][index];
  this.render();
}

  // --- Validation ---
  checkAnswer() {
    if (this.type === "addition") {
      const totalValue =
        this.fixedBlocks.hundreds * 100 +
        this.fixedBlocks.tens * 10 +
        this.fixedBlocks.ones +
        this.userBlocks.hundreds * 100 +
        this.userBlocks.tens * 10 +
        this.userBlocks.ones;
      return totalValue === this.answer;
    }

    if (this.type === "subtraction") {
      if (this.type === "subtraction") {
        const remainingValue =
          this.struck.hundreds.filter(v => !v).length * 100 +
          this.struck.tens.filter(v => !v).length * 10 +
          this.struck.ones.filter(v => !v).length;
        return remainingValue === this.answer;
}

    }

    return false;
  }

  // --- Submit ---
  submit() {
    const result = this.checkAnswer();
      if (this.type === "addition" && this.isRegroupingInvolved) {
        const onesTotal = this.fixedBlocks.ones + this.userBlocks.ones;
        if (onesTotal >= 10) {
          this.showRegroupingCircle();
        }
  }
    if (typeof this.onComplete === "function") {
      this.onComplete(result);
    }
  }

  // --- Render UI inside container ---
render() {
  if (!this.container) return;
  this.container.innerHTML = "";

  const blockArea = document.createElement("div");
  blockArea.className = "block-area";

    // First addend (always visible)
    if (this.type == "addition") {
      this.renderBlocks(blockArea, "hundred", this.fixedBlocks.hundreds, "addend1", this.type==="subtraction", this.struck?.hundreds);
      this.renderBlocks(blockArea, "ten", this.fixedBlocks.tens, "addend1", this.type==="subtraction", this.struck?.tens);
      this.renderBlocks(blockArea, "one", this.fixedBlocks.ones, "addend1", this.type==="subtraction", this.struck?.ones);
    } else {
      this.renderBlocks(blockArea, "hundred", this.fixedBlocks.hundreds, "subtraction", this.type==="subtraction", this.struck?.hundreds);
      this.renderBlocks(blockArea, "ten", this.fixedBlocks.tens, "subtraction", this.type==="subtraction", this.struck?.tens);
      this.renderBlocks(blockArea, "one", this.fixedBlocks.ones, "subtraction", this.type==="subtraction", this.struck?.ones);
    }

    // For addition, also show user blocks (second addend, different color)
    if (this.type === "addition") {
      const userArea = document.createElement("div");
      userArea.className = "block-area";
      this.renderBlocks(userArea, "hundred", this.userBlocks.hundreds, "addend2");
      this.renderBlocks(userArea, "ten", this.userBlocks.tens, "addend2");
      this.renderBlocks(userArea, "one", this.userBlocks.ones, "addend2");
      this.container.appendChild(userArea);
    }

  this.container.appendChild(blockArea);

  const controlsDiv = document.createElement("div");
  controlsDiv.style.marginTop = "12px";
  controlsDiv.style.display = "flex";
  controlsDiv.style.flexWrap = "wrap";
  controlsDiv.style.gap = "8px";

  // Controls (only for addition — add/remove buttons)
if (this.type === "addition") {
  ["hundreds", "tens", "ones"].forEach(type => {
    const plusBtn = document.createElement("button");
    plusBtn.textContent = `+ ${type}`;
    plusBtn.onclick = () => this.addBlock(type);
    controlsDiv.appendChild(plusBtn);

    const minusBtn = document.createElement("button");
    minusBtn.textContent = `- ${type}`;
    minusBtn.onclick = () => this.removeBlock(type);
    controlsDiv.appendChild(minusBtn);
  });

  // break line before submit button
  const br = document.createElement("div");
  br.style.flexBasis = "100%";
  controlsDiv.appendChild(br);

  // add the controlsDiv to the container
  this.container.appendChild(controlsDiv);
  this.controlsDiv = controlsDiv; // save reference for hide/show later
}

const submitBtn = document.createElement("button");
  submitBtn.textContent = "Submit";
  submitBtn.style.marginTop = "10px";
  submitBtn.classList.add("devise-btn");
  submitBtn.onclick = () => this.submit();
  controlsDiv.appendChild(submitBtn);

  this.container.appendChild(controlsDiv);
  this.controlsDiv = controlsDiv;
}

renderBlocks(parent, type, count, addendClass, clickable = false, strikeInfo = null) {
  for (let i = 0; i < count; i++) {
    const div = document.createElement("div");
    div.className = `block ${type} ${addendClass}`;

    // INDEX MATCHES VISUAL POSITION: 0 = leftmost
    div.dataset.index = i;

    if (clickable && this.type === "subtraction") {
      // Apply strike if this block is struck
      if (strikeInfo && strikeInfo[i]) {
        div.classList.add("struck");
      }

      div.onclick = () => this.toggleStrike(type, i);
    }

    parent.appendChild(div);
  }
}

getStrikeKey(type) {
  // normalize both singular and plural inputs
  const map = {
    hundred: "hundreds", hundreds: "hundreds",
    ten: "tens",         tens: "tens",
    one: "ones",         ones: "ones",
  };
  return map[type];
}

showRegroupingCircle() {
  if (!this.container) return;

  // remove any old overlays/labels we created on the body
  document.querySelectorAll(".regroup-overlay-body, .regroup-label-body").forEach(el => el.remove());

  const addend1Ones = Array.from(this.container.querySelectorAll(".block.one.addend1"));
  const addend2Ones = Array.from(this.container.querySelectorAll(".block.one.addend2"));
  if (addend1Ones.length < 1 || addend2Ones.length < 1) return;

  const secondAddendBlocks = addend2Ones;
  const neededFromFirst = Math.max(0, 10 - secondAddendBlocks.length);
  const firstAddendBlocks = addend1Ones.slice(0, neededFromFirst);

  // nothing to draw?
  if (secondAddendBlocks.length === 0 && firstAddendBlocks.length === 0) return;

  // measure & draw in next paint to ensure accurate rects
  requestAnimationFrame(() => {
    const scrollX = window.scrollX || window.pageXOffset;
    const scrollY = window.scrollY || window.pageYOffset;

    const boundsFor = (blocks) => {
      if (!blocks || blocks.length === 0) return null;
      const rects = blocks.map(el => el.getBoundingClientRect());
      const left = Math.min(...rects.map(r => r.left));
      const top = Math.min(...rects.map(r => r.top));
      const right = Math.max(...rects.map(r => r.right));
      const bottom = Math.max(...rects.map(r => r.bottom));
      return { left, top, right, bottom, width: right - left, height: bottom - top };
    };

    const rect2 = boundsFor(secondAddendBlocks);
    const rect1 = boundsFor(firstAddendBlocks);

    const makeOverlay = (rect, color = "red") => {
      if (!rect) return null;
      const ov = document.createElement("div");
      ov.className = "regroup-overlay-body";
      Object.assign(ov.style, {
        position: "absolute",
        left: `${rect.left + scrollX - 8}px`,
        top: `${rect.top + scrollY - 8}px`,
        width: `${rect.width + 16}px`,
        height: `${rect.height + 16}px`,
        border: `3px solid ${color}`,
        borderRadius: "50%",
        backgroundColor: color === "red" ? "rgba(255,0,0,0.06)" : "rgba(0,128,0,0.06)",
        pointerEvents: "none",
        zIndex: "9999"
      });
      document.body.appendChild(ov);
      return ov;
    };

    const circle2 = makeOverlay(rect2, "red");   // user's added ones
    const circle1 = makeOverlay(rect1, "green"); // ones taken from addend1

    // compute union rect for label centering
    const lefts = [];
    const tops = [];
    const rights = [];
    if (rect2) { lefts.push(rect2.left); tops.push(rect2.top); rights.push(rect2.right); }
    if (rect1) { lefts.push(rect1.left); tops.push(rect1.top); rights.push(rect1.right); }
    const unionLeft = Math.min(...lefts);
    const unionTop = Math.min(...tops);
    const unionRight = Math.max(...rights);

    // Create label in page coords (append to body)
    const label = document.createElement("div");
    label.className = "regroup-label-body";
    label.textContent = "10";
    Object.assign(label.style, {
      position: "absolute",
      left: `${((unionLeft + unionRight) / 2) + scrollX}px`,
      top: `${unionTop + scrollY - 36}px`, // 36px above grouped blocks
      transform: "translateX(-50%)",
      padding: "6px 12px",
      background: "white",
      borderRadius: "8px",
      boxShadow: "0 1px 6px rgba(0,0,0,0.25)",
      fontSize: "18px",
      fontWeight: "700",
      color: "blue",
      pointerEvents: "none",
      zIndex: "10000"
    });
    document.body.appendChild(label);

    // If the label overlaps the question text above, nudge label down
    const questionEl = document.getElementById("question-text");
    if (questionEl) {
      const qRect = questionEl.getBoundingClientRect();
      const labelRect = label.getBoundingClientRect();
      const gap = 8;
      const overlap = (qRect.bottom + gap) - labelRect.top;
      if (overlap > 0) {
        // move label down so it doesn't overlap the question
        label.style.top = `${parseFloat(label.style.top) + overlap}px`;
      }
    }
  });
}

clearRegroupingCircles() {
  document.querySelectorAll(".regroup-overlay-body, .regroup-label-body").forEach(el => el.remove());
}

}
