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

puts "\n── Seeding complete ─────────────────────────────────────────\n\n"
