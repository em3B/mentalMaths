
// 🧑‍🤝‍🧑 Diverse set of names (roughly balanced gender-wise)
export const names = [
  "Aaliyah", "Liam", "Sofia", "Noah", "Zara", "Ethan",
  "Amir", "Emily", "Kai", "Fatima", "Anthony", "Chloe",
  "Isaac", "Mei", "Arya", "Omar", "Yuki", "Hugo",
  "Anaya", "Leo", "Priya", "Tariq", "Nia", "Lucas"
];

// 🎒 Familiar classroom items
export const items = [
  "stickers", "marbles", "pencils", "books", "coins", "crayons",
  "sweets", "erasers", "snacks", "toy cars", "lego bricks", "balls",
  "notebooks", "rulers", "magnets", "shells", "blocks"
];

// 🧩 Templates for different bar model problem types
export const templates = {
  partWhole: [
    "{name} has {total} {item}. {pronoun} gave away {part}. How many does {pronounLower} have left?",
    "{name} had {part1} {item}. Then {pronounLower} got {part2} more. How many {item} does {pronounLower} have now?"
  ],
  comparison: [
    "{name1} has {diff} more {item} than {name2}. {name2} has {amount}. How many does {name1} have?",
    "{name1} has {amount} {item}. {name2} has {diff} fewer {item} than {name1}. How many does {name2} have?"
  ],
  multiplicative: [
    "There are {groups} {container}s. Each has {perGroup} {item}. How many {item} are there in total?",
    "{name} has {total} {item}. {pronoun} shares them equally into {groups} boxes. How many in each box?"
  ]
};

// 🔄 Optional: Generate a random container noun
export const containers = ["box", "bag", "jar", "tray", "basket", "bin"];

// 🧠 Helper: Choose pronouns based on name
export function getPronouns(name) {
  // Basic set of female names for this context
  const femaleNames = [
    "Aaliyah", "Sofia", "Zara", "Emily", "Fatima", "Mei", "Arya", "Anaya", "Priya", "Nia", "Chloe"
  ];
  const isFemale = femaleNames.includes(name);
  return {
    pronoun: isFemale ? "She" : "He",
    pronounLower: isFemale ? "she" : "he"
  };
}
