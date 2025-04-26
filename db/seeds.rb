# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Topic.delete_all

topics = [
  {
    title: "Rainbow Pairs (0-10)",
    intro: "Rainbow Pairs help us get to 10 easily. See the rainbow below for number pairs that add up to 10!",
    public: true,
    requires_auth: false
  },
  {
    title: "Rainbow Pairs by Tens (1-100)",
    intro: "Building upon Rainbow Pairs (0-10). This time we use the same idea, except with tens adding up to 100. See the rainbow below!",
    public: false,
    requires_auth: true
  },
  {
    title: "Rainbow Pairs by Hundreds (0-1000)",
    intro: "Building upon Rainbow Pairs (0-10) and Rainbow Pairs (0-100). This time we use the same idea, except with hundreds adding up to 1000. See the rainbow below!",
    public: false,
    requires_auth: true
  },
  {
    title: "Adding to the Nearest Ten",
    intro: "Use our knowledge of Rainbow Pairs to guess the number that would bring us to our next multiple of ten.",
    public: true,
    requires_auth: false
  },
  {
    title: "Subtracting to the Nearest Ten",
    intro: "Use our knowledge of Rainbow Pairs to guess the number that would bring us to our previous multiple of ten",
    public: false,
    requires_auth: true
  },
  {
    title: "Addition: Number Bonds with Rainbow Pairs (Two-Digit Plus One-Digit Numbers)",
    intro: "Make Number Bonds that would help us solve the problem using our knowledge of rainbow pairs. See the examples below",
    public: false,
    requires_auth: true
  },
  {
    title: "Subtraction: Number Bonds with Rainbow Pairs (Two-Digit Minus One-Digit Numbers)",
    intro: "Make Number Bonds that would help us solve the problem using our knowledge of rainbow pairs. See the examples below",
    public: false,
    requires_auth: true
  },
  {
    title: "Subitizing with Ten Frames (0-10)",
    intro: "Visualize groups of 5 and 10 by selecting the number of dots you see. See the examples below.",
    public: true,
    requires_auth: false
  },
  {
    title: "Subitizing with Ten Frames (10-20)",
    intro: "Visualize groups of 5 and 10 by selecting the number of dots you see. See the examples below.",
    public: false,
    requires_auth: true
  },
  {
    title: "Adding Two-Digit and One-Digit Numbers Using Number Bonds",
    intro: "Use the number bonds and your knowledge of rainbow pairs to solve. See example below.",
    public: false,
    requires_auth: true
  },
  {
    title: "Subtracting Two-Digit and One-Digit Numbers Using Number Bonds",
    intro: "Use the number bonds and your knowledge of rainbow pairs to solve. See example below.",
    public: false,
    requires_auth: true
  },
  {
    title: "Count Up and Down By ... From ...",
    intro: "Choose a number to start from. Then choose a number by which to count up and down. See the example below.",
    public: true,
    requires_auth: false
  },
  {
    title: "Add and Subtract by 10 Until 200",
    intro: "Pay special attention to the tens place when you add or subtract 10 each time.",
    public: false,
    requires_auth: true
  },
  {
    title: "Add and Subtract by 100 Until 1000",
    intro: "Pay special attention to the hundreds place when you add or subtract 100 each time.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 2 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 3 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 4 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 5 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 6 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 7 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 8 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 9 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 10 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 11 Starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: Add and Subtract 12 starting from 0",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract.",
    public: false,
    requires_auth: true
  }
]

topics.each do |topic_data|
  Topic.create!(topic_data)
end

puts "Seeded #{topics.size} topics."
