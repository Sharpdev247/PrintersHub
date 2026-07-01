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
  admin.save!
  puts "  [created] AdminUser: #{admin_email}"
else
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

puts "\n── Seeding complete ─────────────────────────────────────────\n\n"
