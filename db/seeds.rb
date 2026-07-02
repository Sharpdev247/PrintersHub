# db/seeds.rb
# Idempotent — safe to run multiple times in any environment.
# Uses find_or_create_by! so re-running never creates duplicates.
# Production: set ADMIN_EMAIL and ADMIN_PASSWORD env vars before running db:seed.

puts "\n── Seeding PrintersHub ──────────────────────────────────────\n\n"

# ── Admin User ────────────────────────────────────────────────────────────────
admin_email    = ENV.fetch("ADMIN_EMAIL",    "admin@printershub.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "ChangeMe123!")

admin = AdminUser.find_or_initialize_by(email: admin_email)
if admin.new_record?
  admin.password              = admin_password
  admin.password_confirmation = admin_password
  admin.role                  = "super_admin"
  admin.super_admin           = true
  admin.active                = true
  admin.save!
  puts "  [created] AdminUser: #{admin_email} (super_admin)"
else
  admin.update!(role: "super_admin", super_admin: true, active: true) if admin.role.blank?
  puts "  [exists]  AdminUser: #{admin_email}"
end

# ── Roles ─────────────────────────────────────────────────────────────────────
# These are the core marketplace participant roles. Additional roles can be added
# here or through ActiveAdmin without a code change.
ROLES = [
  { name: "buyer",            description: "Can browse listings and place orders" },
  { name: "seller",           description: "Can create listings and sell products" },
  { name: "dealer",           description: "Authorised dealer with bulk pricing access" },
  { name: "vendor",           description: "Supplies products to the marketplace" },
  { name: "service_provider", description: "Offers repair and maintenance services" },
  { name: "admin",            description: "Platform administrator with elevated privileges" }
].freeze

ROLES.each do |attrs|
  role = Role.find_or_initialize_by(name: attrs[:name])
  if role.new_record?
    role.description = attrs[:description]
    role.save!
    puts "  [created] Role: #{attrs[:name]}"
  else
    puts "  [exists]  Role: #{attrs[:name]}"
  end
end

# ── Categories ────────────────────────────────────────────────────────────────
# Root categories and their children. ancestry gem handles the tree automatically.
CATEGORY_TREE = [
  {
    name: "Printers",
    children: [
      { name: "Laser Printers" },
      { name: "Inkjet Printers" },
      { name: "Thermal Printers" },
      { name: "Dot Matrix Printers" },
      { name: "3D Printers" }
    ]
  },
  {
    name: "Printer Parts",
    children: [
      { name: "Rollers" },
      { name: "Fusers" },
      { name: "Motors" },
      { name: "Drums" },
      { name: "Paper Trays" }
    ]
  },
  {
    name: "Ink & Toner",
    children: [
      { name: "Ink Cartridges" },
      { name: "Toner Cartridges" },
      { name: "Ink Tanks" }
    ]
  },
  {
    name: "Accessories",
    children: [
      { name: "Print Heads" },
      { name: "Cables & Adapters" },
      { name: "Paper & Media" },
      { name: "Maintenance Kits" }
    ]
  }
].freeze

def find_or_create_category(name:, parent: nil, position: 0)
  category = Category.find_or_initialize_by(name: name)
  if category.new_record?
    category.parent   = parent
    category.position = position
    category.save!
    puts "  [created] Category: #{"  " * (category.depth)}#{name}"
  else
    puts "  [exists]  Category: #{"  " * (category.depth)}#{name}"
  end
  category
end

CATEGORY_TREE.each_with_index do |root_attrs, root_pos|
  root = find_or_create_category(name: root_attrs[:name], position: root_pos)
  (root_attrs[:children] || []).each_with_index do |child_attrs, child_pos|
    find_or_create_category(name: child_attrs[:name], parent: root, position: child_pos)
  end
end

# ── Brands ────────────────────────────────────────────────────────────────────
BRANDS = [
  { name: "HP",       website: "https://www.hp.com" },
  { name: "Canon",    website: "https://www.canon.com" },
  { name: "Epson",    website: "https://www.epson.com" },
  { name: "Brother",  website: "https://www.brother.com" },
  { name: "Lexmark",  website: "https://www.lexmark.com" },
  { name: "Xerox",    website: "https://www.xerox.com" },
  { name: "Ricoh",    website: "https://www.ricoh.com" },
  { name: "Kyocera",  website: "https://www.kyoceradocumentsolutions.com" }
].freeze

BRANDS.each do |attrs|
  brand = Brand.find_or_initialize_by(name: attrs[:name])
  if brand.new_record?
    brand.website = attrs[:website]
    brand.save!
    puts "  [created] Brand: #{attrs[:name]}"
  else
    puts "  [exists]  Brand: #{attrs[:name]}"
  end
end

# ── Printer Models ────────────────────────────────────────────────────────────
laser_category  = Category.find_by(name: "Laser Printers")
inkjet_category = Category.find_by(name: "Inkjet Printers")
hp_brand        = Brand.find_by(name: "HP")
canon_brand     = Brand.find_by(name: "Canon")
epson_brand     = Brand.find_by(name: "Epson")

PRINTER_MODELS = [
  { brand: hp_brand,    category: laser_category,  name: "LaserJet Pro M404n",   model_number: "W1A52A",  release_year: 2019 },
  { brand: hp_brand,    category: laser_category,  name: "LaserJet Pro MFP M428fdw", model_number: "W1A30A", release_year: 2019 },
  { brand: hp_brand,    category: inkjet_category, name: "OfficeJet Pro 9015e",  model_number: "1G5L3A",  release_year: 2021 },
  { brand: canon_brand, category: laser_category,  name: "imageCLASS MF445dw",   model_number: "3514C002", release_year: 2020 },
  { brand: canon_brand, category: inkjet_category, name: "PIXMA G6020",           model_number: "4479C002", release_year: 2019 },
  { brand: epson_brand, category: inkjet_category, name: "EcoTank ET-4850",       model_number: "C11CJ29201", release_year: 2021 }
].freeze

PRINTER_MODELS.each do |attrs|
  next unless attrs[:brand].present? && attrs[:category].present?

  model = PrinterModel.find_or_initialize_by(brand: attrs[:brand], name: attrs[:name])
  if model.new_record?
    model.category     = attrs[:category]
    model.model_number = attrs[:model_number]
    model.release_year = attrs[:release_year]
    model.save!
    puts "  [created] PrinterModel: #{attrs[:brand].name} #{attrs[:name]}"
  else
    puts "  [exists]  PrinterModel: #{attrs[:brand].name} #{attrs[:name]}"
  end
end

# ── Master Data: Countries, States, Cities ───────────────────────────────────
#
# Development seed: Pakistan (primary market) + US + UK + UAE.
#
# PRODUCTION BULK IMPORT NOTE:
#   For full world coverage (250 countries, 5000+ states, 150k+ cities) use the
#   rake task defined in lib/tasks/data_import.rake (to be created in a future
#   milestone). It streams from the countries_states_cities JSON dataset using
#   insert_all for high-throughput upserts without loading all records into memory.
#   Seeds should stay fast — rake tasks handle bulk data.

def seed_country(attrs)
  country = Country.find_or_initialize_by(iso2: attrs[:iso2])
  if country.new_record?
    country.assign_attributes(attrs)
    country.save!
    puts "  [created] Country: #{attrs[:name]} (#{attrs[:iso2]})"
  else
    puts "  [exists]  Country: #{attrs[:name]} (#{attrs[:iso2]})"
  end
  country
end

def seed_state(country:, name:, code: nil)
  state = State.find_or_initialize_by(country: country, name: name)
  if state.new_record?
    state.code = code
    state.save!
    puts "  [created]   State: #{name}"
  else
    puts "  [exists]    State: #{name}"
  end
  state
end

def seed_city(state:, name:, latitude: nil, longitude: nil)
  city = City.find_or_initialize_by(state: state, name: name)
  if city.new_record?
    city.latitude  = latitude
    city.longitude = longitude
    city.save!
    puts "  [created]     City: #{name}"
  else
    puts "  [exists]      City: #{name}"
  end
  city
end

# ── Pakistan ──────────────────────────────────────────────────────────────────
pk = seed_country(
  name:            "Pakistan",
  iso2:            "PK",
  iso3:            "PAK",
  phone_code:      "+92",
  currency_code:   "PKR",
  currency_symbol: "₨",
  continent:       "Asia",
  locale_code:     "en-PK",
  flag_emoji:      "🇵🇰",
  timezone:        "Asia/Karachi",
  display_order:   1,
  active:          true
)

punjab   = seed_state(country: pk, name: "Punjab",               code: "PB")
sindh    = seed_state(country: pk, name: "Sindh",                code: "SD")
kpk      = seed_state(country: pk, name: "Khyber Pakhtunkhwa",   code: "KP")
baloch   = seed_state(country: pk, name: "Balochistan",          code: "BA")
_islamabad = seed_state(country: pk, name: "Islamabad Capital Territory", code: "IS")

# Punjab cities
seed_city(state: punjab, name: "Lahore",       latitude: 31.5204,  longitude: 74.3587)
seed_city(state: punjab, name: "Faisalabad",   latitude: 31.4504,  longitude: 73.1350)
seed_city(state: punjab, name: "Rawalpindi",   latitude: 33.5651,  longitude: 73.0169)
seed_city(state: punjab, name: "Gujranwala",   latitude: 32.1877,  longitude: 74.1945)
seed_city(state: punjab, name: "Multan",       latitude: 30.1575,  longitude: 71.5249)
seed_city(state: punjab, name: "Sialkot",      latitude: 32.4945,  longitude: 74.5229)
seed_city(state: punjab, name: "Bahawalpur",   latitude: 29.3956,  longitude: 71.6722)

# Sindh cities
seed_city(state: sindh, name: "Karachi",       latitude: 24.8607,  longitude: 67.0011)
seed_city(state: sindh, name: "Hyderabad",     latitude: 25.3960,  longitude: 68.3578)
seed_city(state: sindh, name: "Sukkur",        latitude: 27.7052,  longitude: 68.8574)

# KPK cities
seed_city(state: kpk, name: "Peshawar",        latitude: 34.0150,  longitude: 71.5805)
seed_city(state: kpk, name: "Abbottabad",      latitude: 34.1463,  longitude: 73.2117)

# Balochistan cities
seed_city(state: baloch, name: "Quetta",       latitude: 30.1798,  longitude: 66.9750)

# ── United States ──────────────────────────────────────────────────────────────
us = seed_country(
  name:            "United States",
  iso2:            "US",
  iso3:            "USA",
  phone_code:      "+1",
  currency_code:   "USD",
  currency_symbol: "$",
  continent:       "North America",
  locale_code:     "en-US",
  flag_emoji:      "🇺🇸",
  timezone:        "America/New_York",
  display_order:   2,
  active:          true
)

us_ca = seed_state(country: us, name: "California",  code: "CA")
us_ny = seed_state(country: us, name: "New York",     code: "NY")
us_tx = seed_state(country: us, name: "Texas",        code: "TX")
us_il = seed_state(country: us, name: "Illinois",     code: "IL")
us_fl = seed_state(country: us, name: "Florida",      code: "FL")

seed_city(state: us_ca, name: "Los Angeles",   latitude: 34.0522,  longitude: -118.2437)
seed_city(state: us_ca, name: "San Francisco", latitude: 37.7749,  longitude: -122.4194)
seed_city(state: us_ny, name: "New York City", latitude: 40.7128,  longitude: -74.0060)
seed_city(state: us_tx, name: "Houston",       latitude: 29.7604,  longitude: -95.3698)
seed_city(state: us_tx, name: "Dallas",        latitude: 32.7767,  longitude: -96.7970)
seed_city(state: us_il, name: "Chicago",       latitude: 41.8781,  longitude: -87.6298)
seed_city(state: us_fl, name: "Miami",         latitude: 25.7617,  longitude: -80.1918)

# ── United Kingdom ─────────────────────────────────────────────────────────────
gb = seed_country(
  name:            "United Kingdom",
  iso2:            "GB",
  iso3:            "GBR",
  phone_code:      "+44",
  currency_code:   "GBP",
  currency_symbol: "£",
  continent:       "Europe",
  locale_code:     "en-GB",
  flag_emoji:      "🇬🇧",
  timezone:        "Europe/London",
  display_order:   3,
  active:          true
)

gb_eng = seed_state(country: gb, name: "England",  code: "ENG")
gb_sco = seed_state(country: gb, name: "Scotland", code: "SCT")

seed_city(state: gb_eng, name: "London",     latitude: 51.5074,  longitude: -0.1278)
seed_city(state: gb_eng, name: "Manchester", latitude: 53.4808,  longitude: -2.2426)
seed_city(state: gb_sco, name: "Edinburgh",  latitude: 55.9533,  longitude: -3.1883)

# ── United Arab Emirates ───────────────────────────────────────────────────────
ae = seed_country(
  name:            "United Arab Emirates",
  iso2:            "AE",
  iso3:            "ARE",
  phone_code:      "+971",
  currency_code:   "AED",
  currency_symbol: "د.إ",
  continent:       "Asia",
  locale_code:     "ar-AE",
  flag_emoji:      "🇦🇪",
  timezone:        "Asia/Dubai",
  display_order:   4,
  active:          true
)

ae_dubai  = seed_state(country: ae, name: "Dubai",        code: "DU")
ae_abu    = seed_state(country: ae, name: "Abu Dhabi",    code: "AZ")
ae_sharj  = seed_state(country: ae, name: "Sharjah",      code: "SH")

seed_city(state: ae_dubai, name: "Dubai",         latitude: 25.2048,  longitude: 55.2708)
seed_city(state: ae_abu,   name: "Abu Dhabi",     latitude: 24.4539,  longitude: 54.3773)
seed_city(state: ae_sharj, name: "Sharjah",       latitude: 25.3462,  longitude: 55.4211)

# ── Sample Listings ───────────────────────────────────────────────────────────
puts "\n  Seeding sample listings..."

# Grab references needed for listings
seed_user = User.find_or_initialize_by(email: "seller@printershub.com")
if seed_user.new_record?
  seed_user.password              = "SeedUser123!"
  seed_user.password_confirmation = "SeedUser123!"
  seed_user.skip_confirmation!
  seed_user.save!
  puts "  [created] Seed User: seller@printershub.com"
else
  puts "  [exists]  Seed User: seller@printershub.com"
end

# Seller account must exist before listings because account_id is NOT NULL.
seller_account = Account.find_or_initialize_by(name: "PrintersPro Lahore")
if seller_account.new_record?
  seller_account.assign_attributes(
    account_type: :dealer,
    status:       :active,
    email:        "seller@printershub.com",
    verified:     true,
    verified_at:  Time.current
  )
  seller_account.save!
  puts "  [created] Account (early): #{seller_account.name}"
else
  puts "  [exists]  Account (early): #{seller_account.name}"
end

unless Membership.exists?(account: seller_account, user: seed_user)
  Membership.create!(account: seller_account, user: seed_user, role: :owner)
  puts "  [created] Membership: #{seed_user.email} → #{seller_account.name} (owner)"
end

hp     = Brand.find_by!(name: "HP")
canon  = Brand.find_by!(name: "Canon")
epson  = Brand.find_by!(name: "Epson")

printers_cat  = Category.find_by!(name: "Printers")
toner_cat     = Category.find_by(name: "Ink & Toner") || Category.find_by!(name: "Printers")

lahore_city = City.joins(:state).find_by(name: "Lahore")
karachi_city = City.joins(:state).find_by(name: "Karachi")

hp_laserjet = PrinterModel.find_by(name: "LaserJet Pro M404n")

SAMPLE_LISTINGS = [
  {
    title:        "HP LaserJet Pro M404n - Excellent Condition",
    description:  "Selling my HP LaserJet Pro M404n laser printer. Purchased 18 months ago, lightly used in a home office. Print speed up to 40 ppm, duplex printing, USB and Ethernet connectivity. Comes with original box and a nearly full toner cartridge. Perfect for small business or home office use.",
    listing_type: :sale,
    condition:    :like_new,
    price:        45_000,
    currency:     "PKR",
    quantity:     1,
    year:         2023,
    status:       :published,
    featured:     true,
    brand:        hp,
    category:     printers_cat,
    printer_model: hp_laserjet,
    location_city: lahore_city,
  },
  {
    title:        "Canon PIXMA G6020 MegaTank - Barely Used",
    description:  "Canon PIXMA G6020 MegaTank all-in-one printer for sale. Wireless, high-capacity ink tank system. Barely used — only 200 pages printed. Ideal for home users who print frequently. All ink tanks are full. Print, scan, and copy functionality. Excellent colour output quality.",
    listing_type: :sale,
    condition:    :brand_new,
    price:        35_000,
    currency:     "PKR",
    quantity:     1,
    year:         2024,
    status:       :published,
    featured:     false,
    brand:        canon,
    category:     printers_cat,
    printer_model: nil,
    location_city: karachi_city,
  },
  {
    title:        "Epson EcoTank ET-4760 - Good Working Condition",
    description:  "Epson EcoTank ET-4760 wireless all-in-one supertank printer. Good working condition with minor cosmetic scratches on the lid. All four ink tanks are approximately 50% full. Print, copy, scan, and fax. Auto document feeder included. Priced to sell quickly.",
    listing_type: :sale,
    condition:    :good,
    price:        28_000,
    currency:     "PKR",
    quantity:     1,
    year:         2022,
    status:       :draft,
    featured:     false,
    brand:        epson,
    category:     printers_cat,
    printer_model: nil,
    location_city: lahore_city,
  },
].freeze

SAMPLE_LISTINGS.each do |attrs|
  existing = Listing.find_by(title: attrs[:title])
  if existing
    puts "  [exists]  Listing: #{attrs[:title]}"
    next
  end

  listing = Listing.new(
    account:       seller_account,
    user:          seed_user,
    title:         attrs[:title],
    description:   attrs[:description],
    listing_type:  attrs[:listing_type],
    condition:     attrs[:condition],
    price:         attrs[:price],
    currency:      attrs[:currency],
    quantity:      attrs[:quantity],
    year:          attrs[:year],
    status:        attrs[:status],
    featured:      attrs[:featured],
    brand:         attrs[:brand],
    category:      attrs[:category],
    printer_model: attrs[:printer_model],
    location_city: attrs[:location_city],
  )

  if attrs[:status] == :published
    listing.published_at = Time.current
  end

  listing.save!
  puts "  [created] Listing: #{attrs[:title]}"
end

# ── Interaction Layer ─────────────────────────────────────────────────────────
puts "\n  Seeding interaction layer..."

# Seed buyer user
seed_buyer = User.find_or_initialize_by(email: "buyer@printershub.com")
if seed_buyer.new_record?
  seed_buyer.password              = "SeedUser123!"
  seed_buyer.password_confirmation = "SeedUser123!"
  seed_buyer.skip_confirmation!
  seed_buyer.save!
  puts "  [created] Seed Buyer: buyer@printershub.com"
else
  puts "  [exists]  Seed Buyer: buyer@printershub.com"
end

hp_listing = Listing.find_by!(title: "HP LaserJet Pro M404n - Excellent Condition")
canon_listing = Listing.find_by!(title: "Canon PIXMA G6020 MegaTank - Barely Used")

# ── Favorites ────────────────────────────────────────────────────────────────
[hp_listing, canon_listing].each do |listing|
  unless Favorite.exists?(user: seed_buyer, listing: listing)
    Favorite.create!(user: seed_buyer, listing: listing)
    puts "  [created] Favorite: #{seed_buyer.email} → #{listing.title[0..40]}"
  else
    puts "  [exists]  Favorite: #{seed_buyer.email} → #{listing.title[0..40]}"
  end
end

# ── Saved Searches ────────────────────────────────────────────────────────────
saved_search_attrs = [
  {
    name:          "HP Laser Printers Under 50k PKR",
    filters:       { "brand_id" => hp_listing.brand_id, "listing_type" => "sale",
                     "price_max" => 50_000, "currency" => "PKR" },
    alert_enabled: true
  },
  {
    name:          "Any Canon Printer",
    filters:       { "brand_id" => Brand.find_by!(name: "Canon").id },
    alert_enabled: false
  }
]

saved_search_attrs.each do |attrs|
  unless SavedSearch.exists?(user: seed_buyer, name: attrs[:name])
    SavedSearch.create!(user: seed_buyer, **attrs)
    puts "  [created] SavedSearch: #{attrs[:name]}"
  else
    puts "  [exists]  SavedSearch: #{attrs[:name]}"
  end
end

# ── Conversation & Messages ───────────────────────────────────────────────────
conv = Conversation.joins(:conversation_participants)
         .where(listing: hp_listing)
         .where(conversation_participants: { user_id: seed_buyer.id })
         .first

if conv.nil?
  conv = Conversation.between(
    initiator: seed_buyer,
    recipient: seed_user,
    listing:   hp_listing,
    subject:   "Inquiry about HP LaserJet Pro M404n"
  )
  puts "  [created] Conversation ##{conv.id}: #{conv.subject}"
else
  puts "  [exists]  Conversation ##{conv.id}: #{conv.subject}"
end

seed_messages = [
  { user: seed_buyer, body: "Hi! I'm interested in the HP LaserJet. Is the price negotiable?" },
  { user: seed_user,  body: "Hello! Yes, I can consider reasonable offers. What did you have in mind?" },
  { user: seed_buyer, body: "Could you do 40,000 PKR? I can pick it up this weekend." },
]

seed_messages.each do |msg_attrs|
  unless Message.exists?(conversation: conv, user: msg_attrs[:user], body: msg_attrs[:body])
    msg = conv.messages.create!(user: msg_attrs[:user], body: msg_attrs[:body])
    puts "  [created] Message from #{msg_attrs[:user].email}: #{msg_attrs[:body][0..40]}..."
  else
    puts "  [exists]  Message from #{msg_attrs[:user].email}"
  end
end

# ── Offer ─────────────────────────────────────────────────────────────────────
unless Offer.exists?(listing: hp_listing, buyer: seed_buyer)
  offer = Offer.create!(
    listing:     hp_listing,
    buyer:       seed_buyer,
    seller:      seed_user,
    proposed_by: seed_buyer,
    amount:      40_000,
    currency:    "PKR",
    message:     "Willing to pay 40,000 PKR and collect in person this weekend.",
    expires_at:  7.days.from_now
  )
  puts "  [created] Offer ##{offer.id}: #{offer.amount} #{offer.currency} on #{hp_listing.title[0..30]}"
else
  puts "  [exists]  Offer on #{hp_listing.title[0..40]}"
end

# ── Notifications ─────────────────────────────────────────────────────────────
offer = Offer.find_by!(listing: hp_listing, buyer: seed_buyer)

unless Notification.exists?(user: seed_user, notification_type: "offer_received",
                             notifiable: offer)
  Notification.deliver(
    user:       seed_user,
    type:       "offer_received",
    title:      "New offer on #{hp_listing.title[0..40]}",
    body:       "#{seed_buyer.email} offered #{offer.amount} #{offer.currency}",
    data:       { offer_id: offer.id, amount: offer.amount.to_s, currency: offer.currency,
                  listing_id: hp_listing.id, buyer_email: seed_buyer.email },
    notifiable: offer
  )
  puts "  [created] Notification: offer_received for #{seed_user.email}"
else
  puts "  [exists]  Notification: offer_received for #{seed_user.email}"
end

# ── Review ────────────────────────────────────────────────────────────────────
unless Review.exists?(listing: hp_listing, reviewer: seed_buyer)
  Review.create!(
    listing:  hp_listing,
    reviewer: seed_buyer,
    reviewee: seed_user,
    rating:   5,
    body:     "Excellent seller! The printer was exactly as described, well packaged, " \
              "and the transaction was smooth. Would definitely buy from again.",
    status:   :published
  )
  puts "  [created] Review: #{seed_buyer.email} reviewed #{seed_user.email} (5★)"
else
  puts "  [exists]  Review: #{seed_buyer.email} on #{hp_listing.title[0..40]}"
end

# ── Subscription Plans ───────────────────────────────────────────────────────
puts "\n  Seeding subscription plans..."

SUBSCRIPTION_PLANS = [
  {
    name: "Free",
    plan_type: :free,
    monthly_price: 0,
    yearly_price: 0,
    trial_days: 0,
    priority: 0,
    active: true,
    description: "Get started with the basics. No credit card required.",
    features: {
      max_listings:             { type: "limit",   value: "5",         display_name: "Max Listings" },
      featured_listings:        { type: "limit",   value: "0",         display_name: "Featured Listings" },
      max_team_members:         { type: "limit",   value: "1",         display_name: "Team Members" },
      api_access:               { type: "boolean", value: "false",     display_name: "API Access" },
      analytics:                { type: "boolean", value: "false",     display_name: "Analytics" },
      crm_module:               { type: "boolean", value: "false",     display_name: "CRM Module" },
      warehouse_module:         { type: "boolean", value: "false",     display_name: "Warehouse Module" },
      repair_module:            { type: "boolean", value: "false",     display_name: "Repair Module" },
      priority_notifications:   { type: "boolean", value: "false",     display_name: "Priority Notifications" },
      storage_gb:               { type: "limit",   value: "1",         display_name: "Storage (GB)" },
      max_api_requests_per_day: { type: "limit",   value: "0",         display_name: "API Requests / Day" },
      messages_per_day:         { type: "limit",   value: "20",        display_name: "Messages / Day" },
      support_level:            { type: "string",  value: "community", display_name: "Support Level" }
    }
  },
  {
    name: "Silver",
    plan_type: :paid,
    monthly_price: 2_990,
    yearly_price: 29_900,
    trial_days: 14,
    priority: 1,
    active: true,
    description: "For growing businesses ready to list more and sell faster.",
    features: {
      max_listings:             { type: "limit",   value: "50",    display_name: "Max Listings" },
      featured_listings:        { type: "limit",   value: "5",     display_name: "Featured Listings" },
      max_team_members:         { type: "limit",   value: "3",     display_name: "Team Members" },
      api_access:               { type: "boolean", value: "false", display_name: "API Access" },
      analytics:                { type: "boolean", value: "true",  display_name: "Analytics" },
      crm_module:               { type: "boolean", value: "false", display_name: "CRM Module" },
      warehouse_module:         { type: "boolean", value: "false", display_name: "Warehouse Module" },
      repair_module:            { type: "boolean", value: "false", display_name: "Repair Module" },
      priority_notifications:   { type: "boolean", value: "false", display_name: "Priority Notifications" },
      storage_gb:               { type: "limit",   value: "10",    display_name: "Storage (GB)" },
      max_api_requests_per_day: { type: "limit",   value: "0",     display_name: "API Requests / Day" },
      messages_per_day:         { type: "limit",   value: "100",   display_name: "Messages / Day" },
      support_level:            { type: "string",  value: "email", display_name: "Support Level" }
    }
  },
  {
    name: "Gold",
    plan_type: :paid,
    monthly_price: 7_990,
    yearly_price: 79_900,
    trial_days: 14,
    priority: 2,
    active: true,
    description: "For established dealers needing team access, CRM, and API.",
    features: {
      max_listings:             { type: "limit",   value: "500",      display_name: "Max Listings" },
      featured_listings:        { type: "limit",   value: "20",       display_name: "Featured Listings" },
      max_team_members:         { type: "limit",   value: "10",       display_name: "Team Members" },
      api_access:               { type: "boolean", value: "true",     display_name: "API Access" },
      analytics:                { type: "boolean", value: "true",     display_name: "Analytics" },
      crm_module:               { type: "boolean", value: "true",     display_name: "CRM Module" },
      warehouse_module:         { type: "boolean", value: "false",    display_name: "Warehouse Module" },
      repair_module:            { type: "boolean", value: "true",     display_name: "Repair Module" },
      priority_notifications:   { type: "boolean", value: "true",     display_name: "Priority Notifications" },
      storage_gb:               { type: "limit",   value: "50",       display_name: "Storage (GB)" },
      max_api_requests_per_day: { type: "limit",   value: "5000",     display_name: "API Requests / Day" },
      messages_per_day:         { type: "limit",   value: "-1",       display_name: "Messages / Day" },
      support_level:            { type: "string",  value: "priority", display_name: "Support Level" }
    }
  },
  {
    name: "Platinum",
    plan_type: :paid,
    monthly_price: 19_990,
    yearly_price: 199_900,
    trial_days: 30,
    priority: 3,
    active: true,
    description: "Enterprise-grade: unlimited listings, full module suite, dedicated support.",
    features: {
      max_listings:             { type: "limit",   value: "-1",        display_name: "Max Listings" },
      featured_listings:        { type: "limit",   value: "-1",        display_name: "Featured Listings" },
      max_team_members:         { type: "limit",   value: "-1",        display_name: "Team Members" },
      api_access:               { type: "boolean", value: "true",      display_name: "API Access" },
      analytics:                { type: "boolean", value: "true",      display_name: "Analytics" },
      crm_module:               { type: "boolean", value: "true",      display_name: "CRM Module" },
      warehouse_module:         { type: "boolean", value: "true",      display_name: "Warehouse Module" },
      repair_module:            { type: "boolean", value: "true",      display_name: "Repair Module" },
      priority_notifications:   { type: "boolean", value: "true",      display_name: "Priority Notifications" },
      storage_gb:               { type: "limit",   value: "-1",        display_name: "Storage (GB)" },
      max_api_requests_per_day: { type: "limit",   value: "-1",        display_name: "API Requests / Day" },
      messages_per_day:         { type: "limit",   value: "-1",        display_name: "Messages / Day" },
      support_level:            { type: "string",  value: "dedicated", display_name: "Support Level" }
    }
  }
].freeze

SUBSCRIPTION_PLANS.each do |plan_attrs|
  plan = SubscriptionPlan.find_or_initialize_by(name: plan_attrs[:name])
  if plan.new_record?
    plan.assign_attributes(plan_attrs.except(:features))
    plan.save!
    puts "  [created] SubscriptionPlan: #{plan.name}"
  else
    puts "  [exists]  SubscriptionPlan: #{plan.name}"
  end

  plan_attrs[:features].each do |feature_key, feature_attrs|
    pf = PlanFeature.find_or_initialize_by(subscription_plan: plan, feature_key: feature_key.to_s)
    if pf.new_record?
      pf.feature_type  = feature_attrs[:type]
      pf.value         = feature_attrs[:value]
      pf.display_name  = feature_attrs[:display_name]
      pf.save!
    end
  end
end

# ── Coupons ───────────────────────────────────────────────────────────────────
puts "\n  Seeding coupons..."

SEED_COUPONS = [
  {
    code:            "LAUNCH25",
    name:            "Launch Discount 25%",
    discount_type:   :percentage,
    discount_value:  25,
    currency:        "USD",
    max_redemptions: 500,
    expires_at:      6.months.from_now,
    active:          true
  },
  {
    code:            "FREETRIAL30",
    name:            "30 Day Free Trial Extension",
    discount_type:   :free_trial_days,
    discount_value:  30,
    currency:        "USD",
    max_redemptions: 100,
    expires_at:      3.months.from_now,
    active:          true
  }
].freeze

SEED_COUPONS.each do |attrs|
  coupon = Coupon.find_or_initialize_by(code: attrs[:code].upcase)
  if coupon.new_record?
    coupon.assign_attributes(attrs)
    coupon.save!
    puts "  [created] Coupon: #{attrs[:code]}"
  else
    puts "  [exists]  Coupon: #{attrs[:code]}"
  end
end

# ── Accounts & Memberships ────────────────────────────────────────────────────
puts "\n  Seeding accounts and memberships..."

free_plan     = SubscriptionPlan.find_by!(name: "Free")
silver_plan   = SubscriptionPlan.find_by!(name: "Silver")

# Seller account was already created before the listings section above.
seller_account = Account.find_by!(name: "PrintersPro Lahore")
puts "  [exists]  Account: #{seller_account.name}"

# Buyer account
buyer_account = Account.find_or_initialize_by(name: "KarachiPrints")
if buyer_account.new_record?
  buyer_account.assign_attributes(
    account_type: :individual,
    status:       :active,
    email:        "buyer@printershub.com",
    verified:     false
  )
  buyer_account.save!
  puts "  [created] Account: #{buyer_account.name}"
else
  puts "  [exists]  Account: #{buyer_account.name}"
end

unless Membership.exists?(account: buyer_account, user: seed_buyer)
  Membership.create!(account: buyer_account, user: seed_buyer, role: :owner)
  puts "  [created] Membership: #{seed_buyer.email} → #{buyer_account.name} (owner)"
else
  puts "  [exists]  Membership: #{seed_buyer.email} → #{buyer_account.name}"
end

# ── Account Subscriptions ─────────────────────────────────────────────────────
puts "\n  Seeding account subscriptions..."

# Seller on Silver (active paid subscription)
unless AccountSubscription.exists?(account: seller_account, status: AccountSubscription.statuses[:active])
  AccountSubscription.create!(
    account:              seller_account,
    subscription_plan:    silver_plan,
    status:               :active,
    billing_interval:     "monthly",
    current_price:        silver_plan.monthly_price,
    currency:             "USD",
    current_period_start: 1.month.ago,
    current_period_end:   1.month.from_now
  )
  puts "  [created] AccountSubscription: #{seller_account.name} → Silver (active)"
else
  puts "  [exists]  AccountSubscription: #{seller_account.name} → Silver"
end

# Buyer on Free
unless AccountSubscription.exists?(account: buyer_account)
  AccountSubscription.create!(
    account:              buyer_account,
    subscription_plan:    free_plan,
    status:               :active,
    billing_interval:     "monthly",
    current_price:        0,
    currency:             "USD",
    current_period_start: Time.current
  )
  puts "  [created] AccountSubscription: #{buyer_account.name} → Free (active)"
else
  puts "  [exists]  AccountSubscription: #{buyer_account.name} → Free"
end

puts "\n── Seeding complete ─────────────────────────────────────────\n\n"

# ── Currencies ────────────────────────────────────────────────────────────────
puts "\n  Seeding currencies..."

SEED_CURRENCIES = [
  { code: "USD", name: "US Dollar",          symbol: "$",   exchange_rate: 1.0,    is_default: true,  active: true },
  { code: "PKR", name: "Pakistani Rupee",    symbol: "₨",   exchange_rate: 278.5,  is_default: false, active: true },
  { code: "AED", name: "UAE Dirham",         symbol: "د.إ", exchange_rate: 3.67,   is_default: false, active: true },
  { code: "GBP", name: "British Pound",      symbol: "£",   exchange_rate: 0.79,   is_default: false, active: true },
  { code: "EUR", name: "Euro",               symbol: "€",   exchange_rate: 0.92,   is_default: false, active: true },
  { code: "SAR", name: "Saudi Riyal",        symbol: "ر.س", exchange_rate: 3.75,   is_default: false, active: false },
].freeze

SEED_CURRENCIES.each do |attrs|
  currency = Currency.find_or_initialize_by(code: attrs[:code])
  if currency.new_record?
    currency.assign_attributes(attrs)
    currency.save!
    puts "  [created] Currency: #{attrs[:code]} — #{attrs[:name]}"
  else
    puts "  [exists]  Currency: #{attrs[:code]}"
  end
end

# ── Tax Rates ─────────────────────────────────────────────────────────────────
puts "\n  Seeding tax rates..."

SEED_TAX_RATES = [
  { name: "Pakistan GST",       country_code: "PK", state_code: nil,  tax_type: :gst,       rate: 0.17,  active: true,  description: "Standard GST rate for Pakistan" },
  { name: "Pakistan Sales Tax", country_code: "PK", state_code: "SD", tax_type: :sales_tax, rate: 0.175, active: true,  description: "Sindh Sales Tax (SST)" },
  { name: "US No Tax",          country_code: "US", state_code: nil,  tax_type: :sales_tax, rate: 0.0,   active: true,  description: "Default zero tax — US state tax varies" },
  { name: "UAE VAT",            country_code: "AE", state_code: nil,  tax_type: :vat,       rate: 0.05,  active: true,  description: "UAE standard VAT rate" },
  { name: "UK VAT",             country_code: "GB", state_code: nil,  tax_type: :vat,       rate: 0.20,  active: true,  description: "UK standard VAT rate" },
].freeze

SEED_TAX_RATES.each do |attrs|
  existing = TaxRate.find_by(country_code: attrs[:country_code], state_code: attrs[:state_code], tax_type: TaxRate.tax_types[attrs[:tax_type]])
  if existing
    puts "  [exists]  TaxRate: #{attrs[:name]}"
  else
    TaxRate.create!(attrs)
    puts "  [created] TaxRate: #{attrs[:name]}"
  end
end

# ── Milestone 10: Inventory & Warehouse Management ────────────────────────────

puts "\n── Inventory & Warehouse ───────────────────────────────────\n\n"

# Fetch accounts seeded in Milestone 7
seller_account = Account.find_by!(slug: "printerspro-lahore")
buyer_account  = Account.find_by!(slug: "karachiprints")

# ── Warehouses ────────────────────────────────────────────────────────────────
lahore_wh = Warehouse.find_or_initialize_by(account: seller_account, code: "LHE-MAIN")
if lahore_wh.new_record?
  lahore_wh.assign_attributes(
    name:          "Lahore Main Warehouse",
    city:          "Lahore",
    state:         "Punjab",
    country_code:  "PK",
    postal_code:   "54000",
    contact_name:  "Warehouse Manager",
    is_default:    true,
    active:        true
  )
  lahore_wh.save!
  puts "  [created] Warehouse: #{lahore_wh.name}"
else
  puts "  [exists]  Warehouse: #{lahore_wh.name}"
end

karachi_wh = Warehouse.find_or_initialize_by(account: buyer_account, code: "KHI-MAIN")
if karachi_wh.new_record?
  karachi_wh.assign_attributes(
    name:          "Karachi Main Warehouse",
    city:          "Karachi",
    state:         "Sindh",
    country_code:  "PK",
    postal_code:   "75500",
    contact_name:  "Inventory Team",
    is_default:    true,
    active:        true
  )
  karachi_wh.save!
  puts "  [created] Warehouse: #{karachi_wh.name}"
else
  puts "  [exists]  Warehouse: #{karachi_wh.name}"
end

# ── Warehouse Zones ────────────────────────────────────────────────────────────
[
  { warehouse: lahore_wh,  code: "A", name: "Aisle A",   zone_type: "storage" },
  { warehouse: lahore_wh,  code: "R", name: "Receiving", zone_type: "receiving" },
  { warehouse: karachi_wh, code: "A", name: "Aisle A",   zone_type: "storage" },
  { warehouse: karachi_wh, code: "R", name: "Receiving", zone_type: "receiving" },
].each do |z|
  wz = WarehouseZone.find_or_initialize_by(warehouse: z[:warehouse], code: z[:code])
  if wz.new_record?
    wz.assign_attributes(name: z[:name], zone_type: z[:zone_type])
    wz.save!
    puts "  [created] WarehouseZone: #{z[:warehouse].code}/#{z[:code]}"
  else
    puts "  [exists]  WarehouseZone: #{z[:warehouse].code}/#{z[:code]}"
  end
end

# ── Suppliers ─────────────────────────────────────────────────────────────────
sup1 = Supplier.find_or_initialize_by(account: seller_account, code: "CANON-PK")
if sup1.new_record?
  sup1.assign_attributes(
    name: "Canon Pakistan Distributor",
    contact_name: "Sales Team",
    email: "sales@canon-pk.example.com",
    currency: "PKR",
    payment_terms: "NET30",
    lead_time_days: 14,
    country_code: "PK",
    active: true
  )
  sup1.save!
  puts "  [created] Supplier: #{sup1.name}"
else
  puts "  [exists]  Supplier: #{sup1.name}"
end

sup2 = Supplier.find_or_initialize_by(account: seller_account, code: "HP-DIST")
if sup2.new_record?
  sup2.assign_attributes(
    name: "HP Official Distributor",
    contact_name: "B2B Desk",
    email: "b2b@hp-dist.example.com",
    currency: "USD",
    payment_terms: "NET60",
    lead_time_days: 21,
    country_code: "PK",
    active: true
  )
  sup2.save!
  puts "  [created] Supplier: #{sup2.name}"
else
  puts "  [exists]  Supplier: #{sup2.name}"
end

# ── Products ──────────────────────────────────────────────────────────────────
# Fetch existing catalog records for FK references
canon_brand = Brand.find_by(name: "Canon")
hp_brand    = Brand.find_by(name: "HP")

ink_category  = Category.find_by("name ILIKE ?", "%ink%") || Category.first
toner_category = Category.find_by("name ILIKE ?", "%toner%") || Category.first

prod1 = Product.find_or_initialize_by(account: seller_account, sku: "PRD-CANON-INK-BK")
if prod1.new_record?
  prod1.assign_attributes(
    brand:          canon_brand,
    category:       ink_category,
    name:           "Canon PG-745 Black Ink Cartridge",
    description:    "Original Canon black ink cartridge for PIXMA series",
    status:         :active,
    base_cost:      750.00,
    cost_currency:  "PKR",
    weight:         0.08,
    weight_unit:    "kg",
    has_variants:   false,
    track_inventory: true
  )
  prod1.save!
  puts "  [created] Product: #{prod1.name}"
else
  puts "  [exists]  Product: #{prod1.name}"
end

prod2 = Product.find_or_initialize_by(account: seller_account, sku: "PRD-HP-TONER-BK")
if prod2.new_record?
  prod2.assign_attributes(
    brand:          hp_brand,
    category:       toner_category,
    name:           "HP 85A Black LaserJet Toner",
    description:    "Genuine HP toner cartridge for LaserJet Pro series",
    status:         :active,
    base_cost:      3200.00,
    cost_currency:  "PKR",
    weight:         0.65,
    weight_unit:    "kg",
    has_variants:   true,
    track_inventory: true
  )
  prod2.save!
  puts "  [created] Product: #{prod2.name}"
else
  puts "  [exists]  Product: #{prod2.name}"
end

# ── Product Variants ──────────────────────────────────────────────────────────
var1 = ProductVariant.find_or_initialize_by(product: prod1, variant_sku: "VAR-CANON-INK-BK-STD")
if var1.new_record?
  var1.assign_attributes(name: "Standard", options_data: { "type" => "Standard" }, position: 0, active: true)
  var1.save!
  puts "  [created] ProductVariant: #{var1.name} (#{prod1.sku})"
else
  puts "  [exists]  ProductVariant: #{var1.name}"
end

var2 = ProductVariant.find_or_initialize_by(product: prod2, variant_sku: "VAR-HP-TONER-BK-STD")
if var2.new_record?
  var2.assign_attributes(name: "Standard Yield", options_data: { "yield" => "Standard" }, position: 0, active: true)
  var2.save!
  puts "  [created] ProductVariant: #{var2.name} (#{prod2.sku})"
else
  puts "  [exists]  ProductVariant: #{var2.name}"
end

var3 = ProductVariant.find_or_initialize_by(product: prod2, variant_sku: "VAR-HP-TONER-BK-HY")
if var3.new_record?
  var3.assign_attributes(
    name: "High Yield",
    options_data: { "yield" => "High" },
    cost_override: 4800.00,
    position: 1,
    active: true
  )
  var3.save!
  puts "  [created] ProductVariant: #{var3.name} (#{prod2.sku})"
else
  puts "  [exists]  ProductVariant: #{var3.name}"
end

# ── Inventory Items ───────────────────────────────────────────────────────────
inv1 = InventoryItem.find_or_initialize_by(product_variant: var1, warehouse: lahore_wh)
if inv1.new_record?
  inv1.assign_attributes(
    quantity_on_hand:  50,
    reserved_quantity: 0,
    unit_cost:         750.00,
    cost_currency:     "PKR",
    reorder_point:     10,
    reorder_quantity:  50,
    allow_backorders:  false,
    active:            true
  )
  inv1.save!
  puts "  [created] InventoryItem: #{var1.name} @ #{lahore_wh.code} (qty: 50)"
else
  puts "  [exists]  InventoryItem: #{var1.name} @ #{lahore_wh.code}"
end

inv2 = InventoryItem.find_or_initialize_by(product_variant: var2, warehouse: lahore_wh)
if inv2.new_record?
  inv2.assign_attributes(
    quantity_on_hand:  30,
    reserved_quantity: 0,
    unit_cost:         3200.00,
    cost_currency:     "PKR",
    reorder_point:     5,
    reorder_quantity:  20,
    allow_backorders:  false,
    active:            true
  )
  inv2.save!
  puts "  [created] InventoryItem: #{var2.name} @ #{lahore_wh.code} (qty: 30)"
else
  puts "  [exists]  InventoryItem: #{var2.name} @ #{lahore_wh.code}"
end

inv3 = InventoryItem.find_or_initialize_by(product_variant: var3, warehouse: lahore_wh)
if inv3.new_record?
  inv3.assign_attributes(
    quantity_on_hand:  15,
    reserved_quantity: 0,
    unit_cost:         4800.00,
    cost_currency:     "PKR",
    reorder_point:     5,
    reorder_quantity:  20,
    allow_backorders:  false,
    active:            true
  )
  inv3.save!
  puts "  [created] InventoryItem: #{var3.name} @ #{lahore_wh.code} (qty: 15)"
else
  puts "  [exists]  InventoryItem: #{var3.name} @ #{lahore_wh.code}"
end

# ── Reorder Rules ─────────────────────────────────────────────────────────────
[
  { inventory_item: inv1, supplier: sup1, reorder_point: 10, reorder_quantity: 50 },
  { inventory_item: inv2, supplier: sup2, reorder_point: 5,  reorder_quantity: 20 },
  { inventory_item: inv3, supplier: sup2, reorder_point: 5,  reorder_quantity: 20 },
].each do |rule|
  rr = ReorderRule.find_or_initialize_by(inventory_item: rule[:inventory_item])
  if rr.new_record?
    rr.assign_attributes(
      supplier:        rule[:supplier],
      reorder_point:   rule[:reorder_point],
      reorder_quantity: rule[:reorder_quantity],
      auto_order:      false,
      active:          true
    )
    rr.save!
    puts "  [created] ReorderRule: #{rule[:inventory_item].product_variant.name} (point: #{rule[:reorder_point]})"
  else
    puts "  [exists]  ReorderRule: #{rule[:inventory_item].product_variant.name}"
  end
end

# ── Purchase Order ─────────────────────────────────────────────────────────────
po = PurchaseOrder.find_or_initialize_by(account: seller_account, po_number: "PO-2026-00001")
if po.new_record?
  po.assign_attributes(
    supplier:      sup1,
    warehouse:     lahore_wh,
    status:        :draft,
    currency:      "PKR",
    payment_terms: "NET30",
    expected_at:   30.days.from_now,
    notes:         "Initial stock replenishment for Canon ink cartridges"
  )
  po.save!

  PurchaseOrderItem.create!(
    purchase_order:   po,
    product_variant:  var1,
    quantity_ordered: 100,
    unit_cost:        700.00,
    total_cost:       70_000.00
  )
  po.recalculate!
  puts "  [created] PurchaseOrder: #{po.po_number} (Canon ink x100)"
else
  puts "  [exists]  PurchaseOrder: #{po.po_number}"
end

puts "\n── Inventory seeding complete ──────────────────────────────\n\n"

# ── System Settings ───────────────────────────────────────────────────────────
puts "\n── Seeding system settings ─────────────────────────────────"

settings = [
  # General
  { key: "platform.name",            value: "PrintersHub",              value_type: "string",  category: "general",     description: "Public platform name" },
  { key: "platform.tagline",         value: "The Printer Parts Marketplace", value_type: "string", category: "general", description: "Marketing tagline" },
  { key: "platform.support_email",   value: "support@printershub.com",  value_type: "string",  category: "general",     description: "Support contact email" },
  { key: "platform.default_currency",value: "USD",                      value_type: "string",  category: "general",     description: "Default currency code" },
  { key: "platform.default_timezone",value: "UTC",                      value_type: "string",  category: "general",     description: "Default timezone" },

  # Marketplace
  { key: "marketplace.listings_per_page",       value: "24",    value_type: "integer", category: "marketplace", description: "Listings shown per browse page" },
  { key: "marketplace.max_images_per_listing",  value: "10",    value_type: "integer", category: "marketplace", description: "Max images a seller can upload per listing" },
  { key: "marketplace.offer_max_rounds",        value: "5",     value_type: "integer", category: "marketplace", description: "Max counter-offer rounds before offer expires" },
  { key: "marketplace.offer_expiry_hours",      value: "48",    value_type: "integer", category: "marketplace", description: "Hours before an unanswered offer expires" },
  { key: "marketplace.featured_listings_count", value: "6",     value_type: "integer", category: "marketplace", description: "Number of featured listings on homepage" },
  { key: "marketplace.registration_open",       value: "true",  value_type: "boolean", category: "marketplace", description: "Allow new seller registrations" },

  # Commerce
  { key: "commerce.platform_fee_pct",           value: "0.05",  value_type: "float",   category: "commerce",    description: "Platform transaction fee (0.05 = 5%)" },
  { key: "commerce.auto_complete_days",         value: "7",     value_type: "integer", category: "commerce",    description: "Days after delivery before order auto-completes" },
  { key: "commerce.min_order_amount",           value: "1.00",  value_type: "float",   category: "commerce",    description: "Minimum order value in default currency" },
  { key: "commerce.max_order_amount",           value: "50000", value_type: "integer", category: "commerce",    description: "Maximum order value cap" },

  # Email
  { key: "email.from_name",     value: "PrintersHub",              value_type: "string",  category: "email", description: "Sender display name" },
  { key: "email.from_address",  value: "no-reply@printershub.com", value_type: "string",  category: "email", description: "Sender email address" },
  { key: "email.reply_to",      value: "support@printershub.com",  value_type: "string",  category: "email", description: "Reply-to address" },

  # Security
  { key: "security.require_email_confirmation", value: "true",  value_type: "boolean", category: "security", description: "Require email confirmation before first login" },
  { key: "security.session_timeout_hours",      value: "8",     value_type: "integer", category: "security", description: "Idle session timeout in hours" },
  { key: "security.max_login_attempts",         value: "5",     value_type: "integer", category: "security", description: "Failed login attempts before lockout" },

  # API
  { key: "api.enabled",               value: "true",  value_type: "boolean", category: "api", description: "Enable public API access" },
  { key: "api.rate_limit_per_minute", value: "60",    value_type: "integer", category: "api", description: "API requests per minute per token" },
  { key: "api.max_tokens_per_user",   value: "10",    value_type: "integer", category: "api", description: "Max active API tokens per user" },

  # Maintenance
  { key: "maintenance.mode",          value: "false", value_type: "boolean", category: "maintenance", description: "Enable maintenance mode (blocks all user access)" },
  { key: "maintenance.message",       value: "We are performing scheduled maintenance. Back soon!", value_type: "string", category: "maintenance", description: "Message shown during maintenance" },
]

settings.each do |s|
  setting = SystemSetting.find_or_initialize_by(key: s[:key])
  setting.assign_attributes(s)
  setting.save!
  puts "  [setting] #{s[:key]} = #{s[:value]}"
end

puts "\n── System settings seeding complete ────────────────────────\n\n"
