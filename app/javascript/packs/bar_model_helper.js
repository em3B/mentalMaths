export class BarModelHelper {
  constructor(container) {
    this.container = container;
    this.modelType = null;
    this.currentBars = [];
  }

  clearModel() {
    this.container.innerHTML = "";
    this.currentBars = [];
  }

  // 1️⃣ Multiplication (drag equal bars)
loadMultiplicationModel({ groups = 2, unit = 3, onComplete = () => {} }) {
  this.modelType = "multiplication";
  this.clearModel();

  const buttonRow = document.createElement("div");
  buttonRow.style.display = "flex";
  buttonRow.style.gap = "10px";
  buttonRow.style.marginBottom = "10px";
  buttonRow.id = "button-row";

  const addButton = document.createElement("button");
  addButton.textContent = "+ Add Bar";
  addButton.classList.add("devise-btn");

  const removeButton = document.createElement("button");
  removeButton.textContent = "− Take Away Bar";
  removeButton.classList.add("devise-btn");

  const submitButton = document.createElement("button");
  submitButton.textContent = "Submit";
  submitButton.classList.add("devise-btn");

  buttonRow.appendChild(addButton);
  buttonRow.appendChild(removeButton);
  buttonRow.appendChild(submitButton);
  this.container.appendChild(buttonRow);

  const dropZone = document.createElement("div");
  dropZone.className = "drop-zone";
  dropZone.style.display = "flex";
  dropZone.style.flexWrap = "wrap";
  dropZone.style.gap = "10px";
  this.container.appendChild(dropZone);

  const createLabeledBar = () => {
    const bar = this.createBarWithFixedWidth(false);
    const label = document.createElement("span");
    label.textContent = unit;
    label.style.position = "absolute";
    label.style.left = "50%";
    label.style.top = "50%";
    label.style.transform = "translate(-50%, -50%)";
    label.style.fontWeight = "bold";
    label.style.fontSize = "16px";
    bar.style.position = "relative";
    bar.appendChild(label);
    return bar;
  };

  addButton.addEventListener("click", () => {
    if (dropZone.children.length < groups) {
      dropZone.appendChild(createLabeledBar());
    }
  });

  removeButton.addEventListener("click", () => {
    if (dropZone.lastChild) {
      dropZone.removeChild(dropZone.lastChild);
    }
  });

  submitButton.addEventListener("click", () => {
    if (dropZone.children.length === groups) {
      onComplete();
    } else {
      alert(`You need exactly ${groups} bars to represent ${groups} × ${unit}`);
    }
  });

  // ✅ Return controller with bar count access
  return {
    getBarCount: () => dropZone.children.length
  };
}

loadDivisionModel({ groups = 2, unit = 3, onComplete = () => {} } = {}) {
  this.modelType = "division";
  this.clearModel();
  let wasCorrect = null;

  const extractNumber = (val, fallback) => {
    if (typeof val === "number") return val;
    if (typeof val === "string") return parseInt(val, 10) || fallback;
    if (typeof val === "object" && val !== null) {
      if ("groups" in val) return parseInt(val.groups, 10) || fallback;
      if ("unit" in val) return parseInt(val.unit, 10) || fallback;
    }
    return fallback;
  };

  // Fix malformed inputs
  const originalGroups = groups;
  const originalUnit = unit;

  groups = extractNumber(groups, 2);
  unit = extractNumber(unit, 3);

  console.log("Received groups:", originalGroups, "->", groups);
  console.log("Received unit:", originalUnit, "->", unit);

  const correctTotal = groups * unit;

  const instruction = document.createElement("p");
  instruction.textContent = `Which model shows this?`;
  this.container.appendChild(instruction);

  const optionsContainer = document.createElement("div");
  optionsContainer.className = "division-options";
  optionsContainer.style.display = "grid";
  optionsContainer.style.gridTemplateColumns = "1fr 1fr";
  optionsContainer.style.gap = "20px";
  optionsContainer.style.justifyItems = "center";

  const options = [];

  // 1. Add correct option
  options.push({ groups: groups, unit: unit, isCorrect: true });

  // 2. Add "reversed" incorrect option
  if (groups !== unit) {
    options.push({ groups: unit, unit: groups, isCorrect: false });
  }

  // 3. Add random incorrect options
  let attempts = 0;
  while (options.length < 4 && attempts < 50) {
    attempts++;
    const randGroups = Math.floor(Math.random() * 5) + 1;
    const randUnit = Math.floor(Math.random() * 5) + 1;

    const isDuplicate = options.some(opt =>
      opt.groups === randGroups && opt.unit === randUnit
    );

    const isCorrectTotal = randGroups * randUnit === correctTotal;

    if (!isCorrectTotal && !isDuplicate) {
      options.push({ groups: randGroups, unit: randUnit, isCorrect: false });
    }
  }

  // 4. Pad if still under 4
  while (options.length < 4) {
    options.push({ groups: 1, unit: 1, isCorrect: false });
  }

  // 5. Shuffle
  for (let i = options.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [options[i], options[j]] = [options[j], options[i]];
  }

  // 6. Render
  options.forEach(({ groups, unit, isCorrect }) => {
    const option = document.createElement("div");
    option.className = "division-option";
    option.style.border = "2px solid #aaa";
    option.style.padding = "10px";
    option.style.cursor = "pointer";
    option.style.display = "flex";
    option.style.flexDirection = "column";
    option.style.alignItems = "center";
    option.style.gap = "4px";
    option.style.width = "100%";

    for (let i = 0; i < groups; i++) {
      const bar = this.createLabeledBarWithFixedWidth(unit);
      option.appendChild(bar);
    }

    option.addEventListener("click", () => {
      wasCorrect = isCorrect;
      if (isCorrect) {
        option.style.border = "2px solid green";
        onComplete();
      } else {
        option.style.border = "2px solid red";
        setTimeout(() => {
          option.style.border = "2px solid #aaa";
        }, 300);
      }
    });

    optionsContainer.appendChild(option);
  });

  this.container.appendChild(optionsContainer);
  return {
    get isCorrect() {
      return wasCorrect;
    }
  };
}

  // 2️⃣ Addition/Subtraction: Fill in missing parts
  loadAddSubModel({ type = "addition", total = 10, part1 = null, part2 = null, comparison = false, onDropComplete = () => {} }) {
    this.modelType = type;
    this.clearModel();

      // Keep track of filled bars
    const filled = {
      totalBar: false,
      partBars: [false, false]
    };

    const instruction = document.createElement("p");
    instruction.textContent = `Drag numbers from the word problem into the correct bars.`;
    this.container.appendChild(instruction);

     // Word problem number bank
    const numberBank = document.createElement("div");
    numberBank.className = "number-bank";

    let availableNumbers;
    if (type === "addition") {
      availableNumbers = [part1, part2];
    } else if (comparison && type != "addition") {
      availableNumbers = [total, part2];
    } else {
      availableNumbers = [total, part1];
    }
    availableNumbers = availableNumbers.filter(v => v !== null); 

    availableNumbers.forEach(num => {
      const chip = document.createElement("div");
      chip.className = "number-chip";
      chip.dataset.value = num; // adding to the dataset in order to enable targeting the drop 
      chip.textContent = num;
      chip.draggable = true;
      chip.style.cursor = "grab";
      chip.style.padding = "10px 20px";     
      chip.style.fontSize = "20px";         
      chip.style.border = "2px solid #444";   
      chip.style.borderRadius = "8px";      
      chip.style.margin = "5px";              
      chip.style.display = "inline-block";    
      chip.style.backgroundColor = "#f0f0f0";
      chip.addEventListener("dragstart", e => {
        e.dataTransfer.setData("text/plain", num);
      });
      numberBank.appendChild(chip);
    });

    this.container.appendChild(numberBank);

       // Total bar (top)
    const totalBar = this.createTotalBar(total);
    totalBar.classList.add("total-bar");
    this.container.appendChild(totalBar);

    // Parts section (bottom)
    const partRow = document.createElement("div");
    partRow.className = "bar-parts";
    partRow.style.display = "flex";
    partRow.style.gap = "10px";

  const checkIfComplete = () => {
    const isComplete = (
      (type === "addition" && filled.partBars[0] && filled.partBars[1]) ||
      (type === "subtraction" && comparison && filled.totalBar && filled.partBars[1]) ||
      (type === "subtraction" && filled.totalBar && filled.partBars[0])
    );

    if (isComplete) {
      // Remove instruction
      if (instruction && instruction.parentNode) {
        instruction.parentNode.removeChild(instruction);
      }

      // Trigger any other completion logic
      onDropComplete();
    }
  };

    // Two drop zones
  totalBar.addEventListener("dragover", e => e.preventDefault());

  // Add drop listener to totalBar
  totalBar.addEventListener("drop", e => {
    e.preventDefault();
    const val = parseInt(e.dataTransfer.getData("text/plain"), 10);

    if (type === "subtraction" && val === total) {
      totalBar.textContent = val;
      totalBar.style.backgroundColor = "#7AC4BD";

      const dragged = document.querySelector(`.number-chip[data-value='${val}']`);
      if (dragged) dragged.style.display = "none";

      filled.totalBar = true;
      checkIfComplete();
  } else {
    // Invalid drop – optionally flash red
    totalBar.style.backgroundColor = "#ffaaaa";
    setTimeout(() => {
      totalBar.style.backgroundColor = ""; // reset
    }, 300);
  }
  });

  [part1, part2].forEach((value, index) => {
    const partDrop = document.createElement("div");
    partDrop.className = "drop-part";
    partDrop.dataset.index = index;
    partDrop.style.border = "3px dashed #aaa";
    partDrop.style.padding = "10px";
    partDrop.style.width = `${value / total * 100}%`;
    partDrop.style.textAlign = "center";

    if (comparison && index == 1) {
      partDrop.style.backgroundColor = "transparent";
    } else {
      partDrop.style.backgroundColor = "#F0688C";
    }

    partDrop.addEventListener("dragover", e => e.preventDefault());

    partDrop.addEventListener("drop", e => {
      e.preventDefault();
      const val = parseInt(e.dataTransfer.getData("text/plain"), 10);

    if (val === value) {
      partDrop.textContent = val;
      partDrop.style.backgroundColor = "#7AC4BD";

      const dragged = document.querySelector(`.number-chip[data-value='${val}']`);
      if (dragged) dragged.style.display = "none";

      filled.partBars[index] = true;
      checkIfComplete();
    } else {
      // Invalid drop – flash red or ignore
      partDrop.style.backgroundColor = "#ffaaaa";
      setTimeout(() => {
        partDrop.style.backgroundColor = "#F0688C"; // reset
      }, 300);
    }
      });

    partRow.appendChild(partDrop);
  });
  this.container.appendChild(partRow);

  }

  createBar(value, isDraggable = false) {
    const bar = document.createElement("div");
    bar.className = "bar";
    bar.style.width = `${value * 30}px`;
    bar.style.height = "40px";
    bar.style.backgroundColor = "#CDE17B";
    bar.style.margin = "5px";
    bar.style.display = "inline-block";
    bar.style.textAlign = "center";
    bar.style.lineHeight = "30px";
    if (isDraggable) {
      bar.draggable = true;
      bar.style.cursor = "grab";
    }
    return bar;
  }

    createBarWithFixedWidth(isDraggable = false) {
    const bar = document.createElement("div");
    bar.className = "bar";
    bar.style.width = "20%";
    bar.style.height = "40px";
    bar.style.backgroundColor = "#CDE17B";
    bar.style.margin = "5px";
    bar.style.display = "inline-block";
    bar.style.textAlign = "center";
    bar.style.lineHeight = "30px";
    if (isDraggable) {
      bar.draggable = true;
      bar.style.cursor = "grab";
    }
    return bar;
  }

  createLabeledBarWithFixedWidth(unit, draggable = false) {
  const bar = document.createElement("div");
  bar.className = "unit-bar";
  bar.textContent = unit;
  bar.style.backgroundColor = "#F0688C";
  bar.style.color = "white";
  bar.style.fontWeight = "bold";
  bar.style.padding = "6px";
  bar.style.margin = "2px";
  bar.style.borderRadius = "6px";
  bar.style.textAlign = "center";
  bar.style.width = "40%";
  bar.style.boxSizing = "border-box";

  if (draggable) {
    bar.draggable = true;
    bar.style.cursor = "grab";
  }

  return bar;
}

    createTotalBar(value, isDraggable = false) {
    const bar = document.createElement("div");
    bar.className = "bar";
    bar.style.width = "100%";
    bar.style.height = "40px";
    bar.style.backgroundColor = "#CDE17B";
    bar.style.margin = "5px";
    bar.style.display = "inline-block";
    bar.style.textAlign = "center";
    bar.style.lineHeight = "30px";
    if (isDraggable) {
      bar.draggable = true;
      bar.style.cursor = "grab";
    }
    return bar;
  }
}
