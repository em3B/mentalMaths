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
    title: "Rainbow Pairs (1-100)",
    intro: "Building upon Rainbow Pairs (0-10). This time we use the same idea, except with tens adding up to 100. See the rainbow below!",
    public: false,
    requires_auth: true
  },
  {
    title: "Rainbow Pairs (0-1000)",
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
    title: "Number Bonds: Two-Digit Plus One-Digit",
    intro: "Use the number bonds and your knowledge of rainbow pairs to solve. See example below.",
    public: false,
    requires_auth: true
  },
  {
    title: "Number Bonds: Two-Digit Minus One-Digit",
    intro: "Use the number bonds and your knowledge of rainbow pairs to solve. See example below.",
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
    title: "Number Bonds: Two-Digit Plus Two-Digit",
    intro: "Break the two-digit number apart to solve. See example below.",
    public: false,
    requires_auth: true
  },
  {
    title: "Number Bonds: Two-Digit Minus Two-Digit",
    intro: "Break the two-digit number apart to solve. See example below.",
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
    title: "Add and Subtract by 10",
    intro: "Pay special attention to the tens place when you add or subtract 10 each time.",
    public: false,
    requires_auth: true
  },
  {
    title: "Add and Subtract by 100",
    intro: "Pay special attention to the hundreds place when you add or subtract 100 each time.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 2",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 2 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 3",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 3 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 4",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 4 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 5",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 5 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 6",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 6 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 7",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 7 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 8",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 8 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 9",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 0 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 10",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 10 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 11",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 11 starting from 0.",
    public: false,
    requires_auth: true
  },
  {
    title: "Multiplication as Repeated Addition: 12",
    intro: "Practice multiplication as groups of a certain number added together. Add or subtract by 12 starting from 0.",
    public: false,
    requires_auth: true
  }
]

topics.each do |topic_data|
  Topic.create!(topic_data)
end

puts "Seeded #{topics.size} topics."
