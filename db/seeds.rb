# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

topics = [
  # 1
  {
    title: "Rainbow Pairs (0-10)",
    intro: "Rainbow Pairs help us get to 10 easily. See the rainbow below for number pairs that add up to 10!",
    public: true,
    requires_auth: false,
    category: "Rainbow Pairs"
  },
  # 2
  {
    title: "Rainbow Pairs (1-100)",
    intro: "Building upon Rainbow Pairs (0-10). This time we use the same idea, except with tens adding up to 100. See the rainbow below!",
    public: false,
    requires_auth: true,
    category: "Rainbow Pairs"
  },
  # 3
  {
    title: "Rainbow Pairs (0-1000)",
    intro: "Building upon Rainbow Pairs (0-10) and Rainbow Pairs (0-100). This time we use the same idea, except with hundreds adding up to 1000. See the rainbow below!",
    public: false,
    requires_auth: true,
    category: "Rainbow Pairs"
  },
  # 4
  {
    title: "Adding to the Nearest Ten",
    intro: "Find the next multiple of ten.",
    public: true,
    requires_auth: false,
    category: "Addition and Subtraction"
  },
  # 5
  {
    title: "Subtracting to the Nearest Ten",
    intro: "Find the previous multiple of ten",
    public: false,
    requires_auth: true,
    category: "Addition and Subtraction"
  },
  # 6
  {
    title: "Number Bonds: Two-Digit Plus One-Digit",
    intro: "Use the number bonds and your knowledge of rainbow pairs to solve. See example below.",
    public: false,
    requires_auth: true,
    category: "Number Bonds"
  },
  # 7
  {
    title: "Number Bonds: Two-Digit Minus One-Digit",
    intro: "Use the number bonds and your knowledge of rainbow pairs to solve. See example below.",
    public: false,
    requires_auth: true,
    category: "Number Bonds"
  },
  # 8
  {
    title: "Subitizing with Ten Frames (0-10)",
    intro: "How many dots do you see?",
    public: true,
    requires_auth: false,
    category: "Ten Frames"
  },
  # 9
  {
    title: "Subitizing with Ten Frames (10-20)",
    intro: "How many dots do you see?",
    public: false,
    requires_auth: true,
    category: "Ten Frames"
  },
  # 10
  {
    title: "Number Bonds: Two-Digit Plus Two-Digit",
    intro: "Break the two-digit number apart to solve. See example below.",
    public: false,
    requires_auth: true,
    category: "Number Bonds"
  },
  # 11
  {
    title: "Number Bonds: Two-Digit Minus Two-Digit",
    intro: "Break the two-digit number apart to solve. See example below.",
    public: false,
    requires_auth: true,
    category: "Number Bonds"
  },
  # 12
  {
    title: "Count Up and Down By ... From ...",
    intro: "Choose a number to start from. Then choose a number by which to count up and down. See the example below.",
    public: true,
    requires_auth: false,
    category: "Addition and Subtraction"
  },
  # 13
  {
    title: "Add and Subtract by 10",
    intro: "Pay special attention to the tens place when you add or subtract 10 each time.",
    public: false,
    requires_auth: true,
    category: "Addition and Subtraction"
  },
  # 14
  {
    title: "Add and Subtract by 100",
    intro: "Pay special attention to the hundreds place when you add or subtract 100 each time.",
    public: false,
    requires_auth: true,
    category: "Addition and Subtraction"
  },
  # 15
  {
    title: "Multiplication as Repeated Addition: 2",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 2 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 16
  {
    title: "Multiplication as Repeated Addition: 3",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 3 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 17
  {
    title: "Multiplication as Repeated Addition: 4",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 4 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 18
  {
    title: "Multiplication as Repeated Addition: 5",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 5 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 19
  {
    title: "Multiplication as Repeated Addition: 6",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 6 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 20
  {
    title: "Multiplication as Repeated Addition: 7",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 7 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 21
  {
    title: "Multiplication as Repeated Addition: 8",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 8 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 22
  {
    title: "Multiplication as Repeated Addition: 9",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 0 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 23
  {
    title: "Multiplication as Repeated Addition: 10",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 10 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 24
  {
    title: "Multiplication as Repeated Addition: 11",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 11 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 25
  {
    title: "Multiplication as Repeated Addition: 12",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 12 starting from 0.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 26
  {
    title: "Number Bond Fact Families: 1 - 10",
    intro: "List and solve all fact families for a number.",
    public: true,
    requires_auth: false,
    category: "Number Bonds"
  },
  # 27
  {
    title: "Number Bond Fact Families: Two-Digit",
    intro: "List and solve all fact families for a number.",
    public: false,
    requires_auth: true,
    category: "Number Bonds"
  },
  # 28
  {
    title: "Number Bond Fact Families: Three-Digit",
    intro: "List and solve all fact families for a number.",
    public: false,
    requires_auth: true,
    category: "Number Bonds"
  },
  # 29
  {
    title: "Two-Digit Multiplication",
    intro: "Use a number bont to help you solve two-digit multiplication.",
    public: false,
    requires_auth: true,
    category: "Multiplication"
  },
  # 30
  {
    title: "Adding to the Nearest Ten Part 2",
    intro: "Use our knowledge of Rainbow Pairs to guess the number that would bring us to our next multiple of ten.",
    public: true,
    requires_auth: false,
    category: "Addition and Subtraction"
  },
  # 31
  {
    title: "Subtracting to the Nearest Ten Part 2",
    intro: "Use our knowledge of Rainbow Pairs to guess the number that would bring us to our previous multiple of ten",
    public: false,
    requires_auth: true,
    category: "Addition and Subtraction"
  },
  # 32
  {
    title: "Part/Whole: 0 - 10",
    intro: "Create the bar models to help you solve the word problems.",
    public: true,
    requires_auth: false,
    category: "Bar Models"
  },
  # 33
  {
    title: "Part/Whole: 11 - 99",
    intro: "Create the bar models to help you solve the word problems.",
    public: false,
    requires_auth: true,
    category: "Bar Models"
  },
  # 34
  {
    title: "Comparison: 0 - 10",
    intro: "Create the bar models to help you solve the word problems.",
    public: false,
    requires_auth: true,
    category: "Bar Models"
  },
  # 35
  {
    title: "Comparison: 11 - 99",
    intro: "Create the bar models to help you solve the word problems.",
    public: false,
    requires_auth: true,
    category: "Bar Models"
  },
  # 36
  {
    title: "Multiplication: 0 - 10",
    intro: "Create the bar models to help you solve the word problems.",
    public: false,
    requires_auth: true,
    category: "Bar Models"
  },
  # 37
  {
    title: "Multiplication: 11 - 99",
    intro: "Create the bar models to help you solve the word problems.",
    public: false,
    requires_auth: true,
    category: "Bar Models"
  }
]

topics.each do |attrs|
  topic = Topic.find_or_initialize_by(title: attrs[:title])
  topic.update!(attrs)
end

puts "Seeded #{topics.size} topics."
