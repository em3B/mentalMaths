// number_blocks_helper.js
export class NumberBlocksHelper {
  constructor(
    type,
    firstNumber,
    secondNumber,
    container,
    onComplete = null,
    isRegroupingInvolved = false,
    tenRodBreakdownComplete = false
  ) {
    this.type = type;
    this.firstNumber = firstNumber;
    this.secondNumber = secondNumber;
    this.answer =
      type === "addition"
        ? firstNumber + secondNumber
        : firstNumber - secondNumber;

    this.container = container;
    this.onComplete = onComplete;
    this.isRegroupingInvolved = isRegroupingInvolved;
    this.tenRodBreakdownComplete = tenRodBreakdownComplete;

    this.fixedBlocks = NumberBlocksHelper.decomposeNumber(firstNumber);

    if (this.type === "addition") {
      this.secondBlocks = NumberBlocksHelper.decomposeNumber(this.secondNumber);
      this.onesRegroupedFlags = [];
    } else if (this.type === "subtraction") {
      this.struck = {
        tens: Array(this.fixedBlocks.tens).fill(false),
        ones: Array(this.fixedBlocks.ones).fill(false),
      };
      this.onesRegroupedFlags = Array(this.fixedBlocks.ones).fill(false);
    }

    // references to created DOM pieces
    this.userArea = null;
    this.paletteDiv = null;
    this.instructionsDiv = null;
    this.controlsDiv = null;

    // render initially
    this.render();
  }

  // --- helpers ---
  static decomposeNumber(num) {
    return {
      tens: Math.floor((num % 100) / 10),
      ones: num % 10,
    };
  }

  static singularFromKey(key) {
    return key === "tens" ? "ten" : "one";
  }

  static keyFromSingular(s) {
    return s === "ten" ? "tens" : "ones";
  }

  getStrikeKey(type) {
    const map = { ten: "tens", tens: "tens", one: "ones", ones: "ones" };
    return map[type];
  }

  toggleStrike(type, index) {
    if (this.type !== "subtraction") return;

    // ✅ if regrouping required, user cannot strike ones until regrouping done
    if (type === "one" && this.isRegroupingInvolved && !this.tenRodBreakdownComplete) {
      alert("Please regroup first by clicking the last ten rod!");
      return;
    }

    const key = this.getStrikeKey(type);
    if (!this.struck[key]) return;

    this.struck[key][index] = !this.struck[key][index];
    const el = this.container.querySelector(
      `.block.${type}[data-index="${index}"]`
    );
    if (el) el.classList.toggle("struck");
  }

  // --- validation ---
  checkAnswer() {
    if (this.type === "subtraction") {
      let onesLeft = 0;
      let tensLeft = this.fixedBlocks.tens;
      (this.struck.ones || []).forEach((s) => {
        if (!s) onesLeft++;
      });
      (this.struck.tens || []).forEach((s) => {
        if (s) tensLeft--;
      });
      return onesLeft + tensLeft * 10 === this.answer;
    }
    return false; // addition never graded here
  }

  submit() {
    if (typeof this.onComplete === "function") {
      try {
        this.onComplete();
      } catch (err) {
        console.error("onComplete threw:", err);
      }
    }
  }

  // --- rendering / UX ---
  render() {
    if (!this.container) return;
    this.container.innerHTML = "";

    const blockArea = document.createElement("div");
    blockArea.className = "block-area";

    if (this.type === "addition") {
      // addend1
      this.renderStaticBlocks(
        blockArea,
        "ten",
        this.fixedBlocks.tens,
        "addend1"
      );
      this.renderStaticBlocks(
        blockArea,
        "one",
        this.fixedBlocks.ones,
        "addend1"
      );

      // addend2
      this.renderStaticBlocks(
        blockArea,
        "ten",
        this.secondBlocks.tens,
        "addend2"
      );
      this.renderStaticBlocks(
        blockArea,
        "one",
        this.secondBlocks.ones,
        "addend2"
      );

      this.container.appendChild(blockArea);

      if (this.isRegroupingInvolved) {
        this.showRegroupingCircle();
      }
    } else {
      // subtraction
      if (this.isRegroupingInvolved) {
        // Render all tens normally except the last one (special regroup-ten)
        if (this.fixedBlocks.tens > 1) {
          this.renderStaticBlocks(
            blockArea,
            "ten",
            this.fixedBlocks.tens - 1,
            "subtraction",
            true,
            this.struck?.tens
          );
        }

        // Create the last ten rod (special colour)
        const regroupTen = document.createElement("div");
        regroupTen.className = "block ten subtraction regroup-ten";
        regroupTen.dataset.index = this.fixedBlocks.tens - 1;
        blockArea.appendChild(regroupTen);

        // Add ones (normal)
        this.renderStaticBlocks(
          blockArea,
          "one",
          this.fixedBlocks.ones,
          "subtraction",
          true,
          this.struck?.ones
        );

        // Add click listener for regrouping
        regroupTen.addEventListener("click", () => {
          this.breakTenIntoOnes(regroupTen, blockArea);
        });
      } else {
        // subtraction without regrouping
        this.renderStaticBlocks(
          blockArea,
          "ten",
          this.fixedBlocks.tens,
          "subtraction",
          true,
          this.struck?.tens
        );
        this.renderStaticBlocks(
          blockArea,
          "one",
          this.fixedBlocks.ones,
          "subtraction",
          true,
          this.struck?.ones
        );
      }

      this.container.appendChild(blockArea);
    }
  }

  renderStaticBlocks(parent, singularType, count, addendClass, clickable = false, strikeInfo = null) {
    for (let i = 0; i < count; i++) {
      const div = document.createElement("div");
      div.className = `block ${singularType} ${addendClass}`;
      div.dataset.index = i;
      if (clickable && this.type === "subtraction") {
        if (strikeInfo && strikeInfo[i]) div.classList.add("struck");
        div.addEventListener("click", () =>
          this.toggleStrike(singularType, i)
        );
      }
      parent.appendChild(div);
    }
  }

  // --- regrouping (subtraction) ---
  breakTenIntoOnes(regroupTen, parent) {
    if (this.tenRodBreakdownComplete) return;

    // Remove the ten rod visually
    regroupTen.remove();

    // Add ten small unit blocks with regrouped-one class
    const regroupedOnes = [];
    for (let i = 0; i < 10; i++) {
      const one = document.createElement("div");
      one.className = "block one subtraction regrouped-one";
      one.dataset.index = this.fixedBlocks.ones + i;
      // ❌ make regrouped ones NOT clickable
      parent.appendChild(one);
      regroupedOnes.push(one);
    }

    // Determine how many should be struck (based on subtraction amount)
    const onesToStrike = Math.min(this.secondNumber % 10, regroupedOnes.length);

    // Strike through that many regrouped ones automatically
    for (let i = regroupedOnes.length - 1; i >= regroupedOnes.length - onesToStrike; i--) {
      regroupedOnes[i].classList.add("struck");
      this.struck.ones[this.fixedBlocks.ones + i] = true;
    }

    // Update internal tracking
    this.tenRodBreakdownComplete = true;
    this.fixedBlocks.tens -= 1;
    this.fixedBlocks.ones += 10;
    this.struck.ones = Array(this.fixedBlocks.ones).fill(false);

    // ✅ Mark the struck ones in the tracking array
    for (let i = 0; i < onesToStrike; i++) {
      this.struck.ones[i] = true;
    }

    if (typeof this.onComplete === "function") {
      this.onComplete(true);
    }
  }

  // --- regrouping (addition visual cue) ---
  showRegroupingCircle() {
    if (!this.container) return;
    document
      .querySelectorAll(".regroup-overlay-body, .regroup-label-body")
      .forEach((el) => el.remove());

    const ones = Array.from(
      this.container.querySelectorAll(".block.one.addend1, .block.one.addend2")
    );
    if (ones.length < 10) return;

    const firstTen = ones.slice(0, 10);

    requestAnimationFrame(() => {
      const scrollX = window.scrollX || window.pageXOffset;
      const scrollY = window.scrollY || window.pageYOffset;

      const rects = firstTen.map((el) => el.getBoundingClientRect());
      const left = Math.min(...rects.map((r) => r.left));
      const top = Math.min(...rects.map((r) => r.top));
      const right = Math.max(...rects.map((r) => r.right));
      const bottom = Math.max(...rects.map((r) => r.bottom));

      const ov = document.createElement("div");
      ov.className = "regroup-overlay-body";
      Object.assign(ov.style, {
        position: "absolute",
        left: `${left + scrollX - 8}px`,
        top: `${top + scrollY - 8}px`,
        width: `${right - left + 16}px`,
        height: `${bottom - top + 16}px`,
        border: `3px solid red`,
        borderRadius: "50%",
        backgroundColor: "rgba(255,0,0,0.06)",
        pointerEvents: "none",
        zIndex: "9999",
      });
      document.body.appendChild(ov);

      const label = document.createElement("div");
      label.className = "regroup-label-body";
      label.textContent = "10";
      Object.assign(label.style, {
        position: "absolute",
        left: `${(left + right) / 2 + scrollX}px`,
        top: `${top + scrollY - 36}px`,
        transform: "translateX(-50%)",
        padding: "6px 12px",
        background: "white",
        borderRadius: "8px",
        boxShadow: "0 1px 6px rgba(0,0,0,0.25)",
        fontSize: "18px",
        fontWeight: "700",
        color: "blue",
        pointerEvents: "none",
        zIndex: "10000",
      });
      document.body.appendChild(label);

      this.tenRodBreakdownComplete = true;

      if (typeof this.onComplete === "function") {
        this.onComplete(true);
      }
    });
  }

  destroy() {
    if (this.container) {
      this.container.innerHTML = "";
      this.container = null;
    }
    document
      .querySelectorAll(".regroup-overlay-body, .regroup-label-body")
      .forEach((el) => el.remove());
    this.fixedBlocks = null;
    this.secondBlocks = null;
    this.struck = null;
    this.onComplete = null;
    this.controlsDiv = null;
    this.userArea = null;
    this.paletteDiv = null;
    this.instructionsDiv = null;
  }
}