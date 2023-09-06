# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
if Rails.env.development?
  puts 'Creating the default user environment...'

  User.create!(
    first_name: 'Support',
    last_name: 'Admin',
    super_admin: true,
    role: User.roles[:admin],
    email: 'user@example.com',
    password: 'password',
    password_confirmation: 'password'
  )
end
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
