export class NumberBlocksHelper {
  constructor(type, firstNumber, secondNumber, container, onComplete = null) {
    this.type = type; // "addition" or "subtraction"
    this.firstNumber = firstNumber;
    this.secondNumber = secondNumber;
    this.answer = (type === "addition")
      ? firstNumber + secondNumber
      : firstNumber - secondNumber;

    this.container = container;  // HTML element
    this.onComplete = onComplete;

    // Decompose the first number into blocks
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

    // Build the UI
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

}
