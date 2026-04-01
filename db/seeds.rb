puts "Cleaning database..."
User.destroy_all

puts "Creating 6 unique users..."

users_data = [
  { name: "Satej Patil", email: "satej@example.com", dept: "IT" },
  { name: "Vidya Sharma",  email: "vidya@example.com", dept: "HR" },
  { name: "Rohan Kumbhar",   email: "rohan@example.com", dept: "Operations" },
  { name: "Sana Sonar",    email: "sana@example.com", dept: "Marketing" },
  { name: "Vikram Vaidya",  email: "vikram@example.com", dept: "Finance" },
  { name: "Priya Aurora",   email: "priya@example.com", dept: "Design" }
]

users_data.each do |data|
  User.create!(
    name: data[:name],
    email: data[:email],
    password: "password123",
    password_confirmation: "password123",
    department: data[:dept]
  )
end

puts "Successfully created #{User.count} users!"
