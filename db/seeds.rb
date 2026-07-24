# Idempotent seed data for the store.
# This keeps existing records and adds only missing admin/catalog entries.

if Rails.env.production?
  abort "ERROR: Seeds are not intended for production. Use DISABLE_SEED_GUARD=1 to override." unless ENV["DISABLE_SEED_GUARD"]
end

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "Admin@12345")
admin_name = ENV.fetch("ADMIN_NAME", "Store Admin")

existing_admin = User.find_by(admin: true)
unless existing_admin
  candidate = User.first
  if candidate
    candidate.update!(admin: true)
    puts "Promoted existing user to admin: #{candidate.email}"
  else
    created_admin = User.create!(
      name: admin_name,
      email: admin_email,
      password: admin_password,
      password_confirmation: admin_password,
      admin: true
    )
    puts "Created admin user: #{created_admin.email}"
  end
end

category_map = {}

[
  [ "Smartphones", "Latest Android and iOS phones popular with Kenyan shoppers." ],
  [ "Laptops", "Work and school laptops for students, professionals, and creators." ],
  [ "Home Appliances", "Reliable appliances for home kitchens and daily use." ],
  [ "Fashion", "Everyday fashion items inspired by top online marketplace trends." ],
  [ "Beauty", "Beauty and personal care essentials for daily routines." ],
  [ "Gaming", "Console and PC accessories for gamers and streamers." ],
  [ "Groceries", "Pantry staples, snacks, and local supermarket essentials." ],
  [ "Accessories", "Affordable everyday add-ons and mobile accessories." ]
].each do |name, description|
  category_map[name] = Category.find_or_create_by!(name: name) do |category|
    category.description = description
  end
end

products = [
  { category: "Smartphones", name: "Tecno Spark 20 Pro", description: "6.8-inch display smartphone with 256GB storage and all-day battery life.", price: 28999.00, sku: "KE-SPARK20PRO-256", qty: 24 },
  { category: "Smartphones", name: "Samsung Galaxy A25", description: "5G-ready midrange phone with bright AMOLED screen and quality cameras.", price: 34999.00, sku: "KE-GALAXYA25-128", qty: 18 },
  { category: "Smartphones", name: "Infinix Hot 40i", description: "Budget-friendly phone with large display, strong battery, and smooth daily performance.", price: 16999.00, sku: "KE-HOT40I-128", qty: 32 },
  { category: "Smartphones", name: "Redmi Note 13", description: "Feature-rich smartphone with vivid display and reliable camera setup.", price: 27999.00, sku: "KE-REDMI-NOTE13", qty: 20 },
  { category: "Laptops", name: "HP 15 Core i5 8GB/512GB SSD", description: "Reliable laptop for office work, browsing, and online classes.", price: 78999.00, sku: "KE-HP15-I5-8-512", qty: 10 },
  { category: "Laptops", name: "Lenovo IdeaPad 3 Ryzen 5", description: "Balanced performance laptop with fast SSD and strong battery backup.", price: 72999.00, sku: "KE-IDEAPAD3-R5", qty: 9 },
  { category: "Laptops", name: "Dell Latitude 5420", description: "Durable business laptop for remote work and productivity tasks.", price: 85999.00, sku: "KE-DELL-5420", qty: 8 },
  { category: "Laptops", name: "Acer Aspire 5", description: "Versatile laptop for students, creators, and everyday multitasking.", price: 69999.00, sku: "KE-ACER-ASPIRE5", qty: 11 },
  { category: "Home Appliances", name: "Ramtons 20L Microwave Oven", description: "Compact microwave with multiple heating modes for quick meals.", price: 12499.00, sku: "KE-RAMTONS-MW20L", qty: 16 },
  { category: "Home Appliances", name: "Von 2-Slice Toaster", description: "Fast breakfast toaster with adjustable browning and easy cleaning.", price: 3999.00, sku: "KE-VON-TOASTER2", qty: 30 },
  { category: "Home Appliances", name: "Mika Standing Fan", description: "Sturdy standing fan for cooling living rooms and bedrooms.", price: 7499.00, sku: "KE-MIKA-FAN-16", qty: 15 },
  { category: "Home Appliances", name: "Nexus Digital Cooker", description: "Multi-purpose rice cooker for quick family meals and meal prep.", price: 8999.00, sku: "KE-NEXUS-COOKER", qty: 13 },
  { category: "Fashion", name: "Men's Casual Sneakers", description: "Comfortable daily sneakers suitable for city travel and casual wear.", price: 3299.00, sku: "KE-MENS-SNK-42", qty: 40 },
  { category: "Fashion", name: "Women's Handbag Classic Tote", description: "Spacious tote handbag for office, errands, and weekend outings.", price: 2599.00, sku: "KE-WOMEN-TOTE-01", qty: 26 },
  { category: "Fashion", name: "Kitenge Shirt", description: "Smart casual shirt with bold East African print styling.", price: 1899.00, sku: "KE-KITENGE-SHIRT", qty: 22 },
  { category: "Fashion", name: "Denim Jacket", description: "Classic denim jacket for cool Nairobi evenings and layering.", price: 2999.00, sku: "KE-DENIM-JACKET", qty: 19 },
  { category: "Beauty", name: "Nivea Nourishing Body Lotion 400ml", description: "Moisturizing body lotion for smooth skin in dry and cool weather.", price: 899.00, sku: "KE-NIVEA-400ML", qty: 55 },
  { category: "Beauty", name: "Maybelline Fit Me Foundation", description: "Lightweight foundation with natural finish for daily makeup looks.", price: 1699.00, sku: "KE-MAYBELLINE-FM", qty: 22 },
  { category: "Beauty", name: "African Black Soap", description: "Natural cleansing soap suitable for face and body care routines.", price: 499.00, sku: "KE-BLACKSOAP-01", qty: 48 },
  { category: "Beauty", name: "Hair Growth Oil", description: "Nourishing oil blend for scalp care, growth support, and shine.", price: 1199.00, sku: "KE-HAIR-OIL-01", qty: 28 },
  { category: "Gaming", name: "Sony PS5 DualSense Controller", description: "Original wireless controller with responsive triggers and haptics.", price: 12499.00, sku: "KE-PS5-DUALSENSE", qty: 14 },
  { category: "Gaming", name: "Logitech G102 Gaming Mouse", description: "Precise and lightweight wired gaming mouse with RGB lighting.", price: 2999.00, sku: "KE-LOGI-G102", qty: 36 },
  { category: "Gaming", name: "HyperX Cloud Stinger Headset", description: "Comfortable headset for gaming, streaming, and online meetings.", price: 8499.00, sku: "KE-HYPERX-STINGER", qty: 17 },
  { category: "Gaming", name: "Xbox Wireless Controller", description: "Responsive controller for console and PC gaming setups.", price: 10999.00, sku: "KE-XBOX-CONTROLLER", qty: 12 },
  { category: "Groceries", name: "Premium Kenyan Coffee", description: "Rich and aromatic AA ground coffee from the highlands.", price: 850.00, sku: "KE-KENYA-COFFEE", qty: 40 },
  { category: "Groceries", name: "Macadamia Nuts", description: "Crunchy and salted macadamia nuts, a perfect healthy snack.", price: 1100.00, sku: "KE-MACADAMIA-01", qty: 30 },
  { category: "Groceries", name: "Raw Honey", description: "Pure, organic honey harvested from local beehives.", price: 950.00, sku: "KE-RAW-HONEY-01", qty: 20 },
  { category: "Groceries", name: "Basmati Rice 2kg", description: "Fragrant rice for pilau, biryani, and family meals.", price: 650.00, sku: "KE-BASMATI-2KG", qty: 44 },
  { category: "Accessories", name: "Fast Charging USB-C Cable", description: "Durable cable for charging phones, tablets, and power banks.", price: 499.00, sku: "KE-USBC-CABLE-01", qty: 70 },
  { category: "Accessories", name: "Power Bank 20000mAh", description: "Portable power bank for backup charging during travel and outages.", price: 2499.00, sku: "KE-POWERBANK-20K", qty: 23 },
  { category: "Accessories", name: "Bluetooth Earbuds", description: "Compact wireless earbuds for calls, music, and daily commuting.", price: 3999.00, sku: "KE-EARBUDS-BT01", qty: 34 },
  { category: "Accessories", name: "Phone Case Set", description: "Protective phone case set for common smartphone models.", price: 699.00, sku: "KE-PHONECASE-SET", qty: 45 }
]

products.each do |entry|
  product = Product.find_or_initialize_by(name: entry[:name])
  product.category = category_map.fetch(entry[:category])
  product.description = entry[:description]
  product.price = entry[:price]
  product.save! if product.new_record? || product.changed?

  variant = product.variants.find_or_initialize_by(sku: entry[:sku])
  variant.name = "Standard"
  variant.price = entry[:price]
  variant.quantity = entry[:qty]
  variant.save! if variant.new_record? || variant.changed?
end

# Seed blog categories
blog_categories_data = [
  { name: "Product Reviews", description: "In-depth reviews of our latest products and recommendations", position: 1 },
  { name: "How-To Guides", description: "Step-by-step guides to help you get the most from your purchases", position: 2 },
  { name: "Tech News", description: "Latest technology trends and industry updates", position: 3 },
  { name: "Tips & Tricks", description: "Helpful tips and tricks for smarter shopping and product use", position: 4 },
  { name: "Customer Stories", description: "Real stories from our satisfied customers", position: 5 }
]

blog_categories_data.each do |data|
  BlogCategory.find_or_create_by!(slug: data[:name].parameterize) do |category|
    category.name = data[:name]
    category.description = data[:description]
    category.position = data[:position]
  end
end

puts "Seed complete: #{Category.count} categories, #{Product.count} products, #{Variant.count} variants, #{BlogCategory.count} blog categories"
