# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# delete prev records
Visit.delete_all
Purchase.delete_all
Pass.delete_all
User.delete_all

admin = User.create!(
  email: "admin@example.com",
  password: "password",
  role: :admin
)

client = User.create!(
  email: "client@example.com",
  password: "password",
  role: :client
)

client_no_purchases = User.create!(
  email: "client_nopurchases@example.com",
  password: "password",
  role: :client
)


client_used_up = User.create!(
  email: "client_usedup@example.com",
  password: "password",
  role: :client
)


pass_yoga = Pass.create!(
  name: "Yoga Basic",
  visits: 5,
  expires_at: Date.today + 30,
  price: 100.00,
  user_id: admin.id
)

pass_crossfit = Pass.create!(
  name: "Crossfit Pro",
  visits: 8,
  expires_at: Date.today + 45,
  price: 200.00,
  user_id: admin.id
)

pass_pilates = Pass.create!(
  name: "Pilates 3",
  visits: 3,
  expires_at: Date.today + 20,
  price: 90.00,
  user_id: admin.id
)

purchase_client = Purchase.create!(
  user_id: client.id,
  pass_id: pass_yoga.id,
  remaining_visits: 3,
  purchase_date: Time.current,
  price: pass_yoga.price,
  valid_until: Date.today + 30
)

3.times do |i|
  Visit.create!(
    purchase_id: purchase_client.id,
    visited_at: Time.current - (i + 1).days
  )
end


Purchase.create!(
  user_id: client_used_up.id,
  pass_id: pass_crossfit.id,
  remaining_visits: 0,
  purchase_date: Time.current,
  price: pass_crossfit.price,
  valid_until: Date.today + 30
)
