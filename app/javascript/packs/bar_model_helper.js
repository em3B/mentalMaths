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
  loadMultiplicationModel(groups = 2, unit = 3) {
    this.modelType = "multiplication";
    this.clearModel();

    const instruction = document.createElement("p");
    instruction.textContent = `Drag ${groups} bars of size ${unit} to represent ${groups} × ${unit}`;
    this.container.appendChild(instruction);

    const barBank = document.createElement("div");
    barBank.className = "bar-bank";

    // Create draggable unit bar
    const unitBar = this.createBar(unit, true);
    unitBar.addEventListener("dragstart", e => {
      e.dataTransfer.setData("text/plain", unit);
    });
    barBank.appendChild(unitBar);
    this.container.appendChild(barBank);

    const dropZone = document.createElement("div");
    dropZone.className = "drop-zone";
    dropZone.addEventListener("dragover", e => e.preventDefault());
    dropZone.addEventListener("drop", e => {
      e.preventDefault();
      const val = e.dataTransfer.getData("text/plain");
      if (dropZone.children.length < groups) {
        const dropped = this.createBar(val);
        dropZone.appendChild(dropped);
      }
    });

    this.container.appendChild(dropZone);
  }

  // 2️⃣ Addition/Subtraction: Fill in missing parts
  loadAddSubModel({ type = "addition", total = 10, part1 = null, part2 = null, onDropComplete = () => {} }) {
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
    partDrop.style.backgroundColor = "#F0688C";
    partDrop.style.border = "3px dashed #aaa";
    partDrop.style.padding = "10px";
    partDrop.style.width = `${value / total * 100}%`;
    partDrop.style.textAlign = "center";

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
