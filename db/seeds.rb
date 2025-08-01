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

# Create user
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

# Create pass
pass1 = Pass.create!(
  name: "Yoga Basic",
  visits: 5,
  expires_at: Date.today + 30,
  price: 100.00,
  user_id: admin.id
)

pass2 = Pass.create!(
  name: "Crossfit Pro",
  visits: 8,
  expires_at: Date.today + 45,
  price: 200.00,
  user_id: admin.id
)

# Create purchase (acc pass)
purchase1 = Purchase.create!(
  user_id: client.id,
  pass_id: pass1.id,
  remaining_visits: 5,
  purchase_date: Time.current,
  price: pass1.price,
  valid_until: Date.today + 30
)

# Create visits
3.times do
  Visit.create!(
    purchase_id: purchase1.id,
    attended: true
  )
end

2.times do
  Visit.create!(
    purchase_id: purchase1.id,
    attended: false
  )
end
