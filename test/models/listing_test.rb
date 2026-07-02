require "test_helper"

class ListingTest < ActiveSupport::TestCase
  # ── Fixtures ───────────────────────────────────────────────────────────────

  def hp_laser
    listings(:hp_laser)
  end

  def canon_inkjet
    listings(:canon_inkjet)
  end

  def draft_listing
    listings(:draft_listing)
  end

  def seller_account
    accounts(:seller_account)
  end

  def seller
    users(:seller)
  end

  # ── Validity helpers ───────────────────────────────────────────────────────

  def valid_attrs(overrides = {})
    {
      account:      seller_account,
      user:         seller,
      category:     categories(:printers),
      brand:        brands(:hp),
      title:        "A valid listing title for testing purposes",
      description:  "This is a detailed description of the listing item with enough content to pass validation.",
      listing_type: :sale,
      condition:    :good,
      price:        10_000,
      currency:     "PKR",
      quantity:     1,
      status:       :draft
    }.merge(overrides)
  end

  # ── Associations ───────────────────────────────────────────────────────────

  test "belongs to account (required)" do
    l = Listing.new(valid_attrs(account: nil))
    assert_not l.valid?
    assert_includes l.errors[:account], "must exist"
  end

  test "belongs to user (required)" do
    l = Listing.new(valid_attrs(user: nil))
    assert_not l.valid?
    assert_includes l.errors[:user], "must exist"
  end

  test "belongs to category (required)" do
    l = Listing.new(valid_attrs(category: nil))
    assert_not l.valid?
    assert_includes l.errors[:category], "must exist"
  end

  test "belongs to brand (required)" do
    l = Listing.new(valid_attrs(brand: nil))
    assert_not l.valid?
    assert_includes l.errors[:brand], "must exist"
  end

  # ── Validations ────────────────────────────────────────────────────────────

  test "valid with all required attributes" do
    assert Listing.new(valid_attrs).valid?
  end

  test "invalid without title" do
    l = Listing.new(valid_attrs(title: ""))
    assert_not l.valid?
    assert_includes l.errors[:title], "can't be blank"
  end

  test "invalid with title shorter than 5 characters" do
    l = Listing.new(valid_attrs(title: "HP"))
    assert_not l.valid?
    assert l.errors[:title].any?
  end

  test "invalid with title longer than 200 characters" do
    l = Listing.new(valid_attrs(title: "A" * 201))
    assert_not l.valid?
    assert l.errors[:title].any?
  end

  test "invalid without description" do
    l = Listing.new(valid_attrs(description: ""))
    assert_not l.valid?
    assert_includes l.errors[:description], "can't be blank"
  end

  test "invalid with description shorter than 20 characters" do
    l = Listing.new(valid_attrs(description: "Too short"))
    assert_not l.valid?
    assert l.errors[:description].any?
  end

  test "invalid without price" do
    l = Listing.new(valid_attrs(price: nil))
    assert_not l.valid?
    assert l.errors[:price].any?
  end

  test "invalid with price zero or negative" do
    [ 0, -100 ].each do |bad_price|
      l = Listing.new(valid_attrs(price: bad_price))
      assert_not l.valid?, "expected invalid for price=#{bad_price}"
    end
  end

  test "invalid without currency" do
    l = Listing.new(valid_attrs(currency: ""))
    assert_not l.valid?
    assert l.errors[:currency].any?
  end

  test "invalid with non-ISO currency code" do
    l = Listing.new(valid_attrs(currency: "dollars"))
    assert_not l.valid?
    assert l.errors[:currency].any?
  end

  test "valid with 3-letter ISO currency" do
    %w[USD PKR GBP AED EUR].each do |code|
      l = Listing.new(valid_attrs(currency: code))
      assert l.valid?, "expected valid for currency=#{code}"
    end
  end

  test "invalid with negative quantity" do
    l = Listing.new(valid_attrs(quantity: -1))
    assert_not l.valid?
    assert l.errors[:quantity].any?
  end

  test "valid with zero quantity (out of stock)" do
    assert Listing.new(valid_attrs(quantity: 0)).valid?
  end

  test "invalid with year before 1950" do
    l = Listing.new(valid_attrs(year: 1949))
    assert_not l.valid?
    assert l.errors[:year].any?
  end

  test "valid with nil year (optional)" do
    assert Listing.new(valid_attrs(year: nil)).valid?
  end

  test "invalid with non-existent listing_type raises ArgumentError" do
    assert_raises(ArgumentError) { Listing.new(valid_attrs(listing_type: "auction")) }
  end

  test "invalid with non-existent condition raises ArgumentError" do
    assert_raises(ArgumentError) { Listing.new(valid_attrs(condition: "mint")) }
  end

  test "invalid with non-existent status raises ArgumentError" do
    assert_raises(ArgumentError) { Listing.new(valid_attrs(status: "deleted")) }
  end

  test "published listing requires published_at" do
    l = Listing.new(valid_attrs(status: :published, published_at: nil))
    assert_not l.valid?
    assert l.errors[:published_at].any?
  end

  test "draft listing does not require published_at" do
    assert Listing.new(valid_attrs(status: :draft, published_at: nil)).valid?
  end

  # ── Enums ──────────────────────────────────────────────────────────────────

  test "all status values are string-backed" do
    Listing.statuses.each do |key, val|
      assert_equal key, val, "status '#{key}' should be string-backed, got '#{val}'"
    end
  end

  test "all condition values are string-backed" do
    Listing.conditions.each do |key, val|
      assert_equal key, val, "condition '#{key}' should be string-backed, got '#{val}'"
    end
  end

  test "all listing_type values are string-backed" do
    Listing.listing_types.each do |key, val|
      assert_equal key, val, "listing_type '#{key}' should be string-backed, got '#{val}'"
    end
  end

  test "status includes paused" do
    assert Listing.statuses.key?("paused")
  end

  # ── Scopes ─────────────────────────────────────────────────────────────────

  test "published scope returns only published kept listings" do
    results = Listing.published
    assert results.all?(&:status_published?), "published scope must return only published listings"
    assert results.all? { |l| l.discarded_at.nil? }, "published scope must exclude discarded"
  end

  test "draft scope returns only draft listings" do
    assert Listing.draft.all?(&:status_draft?)
  end

  test "featured scope returns only featured listings" do
    assert Listing.featured.all?(&:featured?)
  end

  test "live scope includes published and sold" do
    live_statuses = Listing.live.map(&:status).uniq
    live_statuses.each do |s|
      assert_includes %w[published sold], s
    end
  end

  test "kept scope excludes discarded listings" do
    hp_laser.discard!
    assert_not Listing.kept.include?(hp_laser)
    hp_laser.undiscard!
  end

  # ── Soft delete (Discard) ──────────────────────────────────────────────────

  test "discarding a listing sets discarded_at" do
    assert_nil hp_laser.discarded_at
    hp_laser.discard!
    assert_not_nil hp_laser.reload.discarded_at
    hp_laser.undiscard!
  end

  test "undiscarding a listing clears discarded_at" do
    hp_laser.discard!
    hp_laser.undiscard!
    assert_nil hp_laser.reload.discarded_at
  end

  test "discarded? returns true after discard" do
    hp_laser.discard!
    assert hp_laser.discarded?
    hp_laser.undiscard!
  end

  # ── State transitions ──────────────────────────────────────────────────────

  test "publish! sets status to published and sets published_at" do
    draft_listing.publish!
    assert draft_listing.status_published?
    assert_not_nil draft_listing.published_at
  end

  test "archive! sets status to archived" do
    hp_laser.archive!
    assert hp_laser.status_archived?
  end

  test "mark_sold! sets status to sold" do
    hp_laser.mark_sold!
    assert hp_laser.status_sold?
  end

  test "pause! sets status to paused" do
    hp_laser.pause!
    assert hp_laser.status_paused?
  end

  # ── View counter ──────────────────────────────────────────────────────────

  test "increment_view! increases views_count by 1" do
    before = hp_laser.views_count
    hp_laser.increment_view!
    assert_equal before + 1, hp_laser.reload.views_count
  end

  test "increment_view! uses SQL update and does not trigger callbacks" do
    # If callbacks ran, audited would insert an audit record.
    before_audits = Audited::Audit.where(auditable: hp_laser).count
    hp_laser.increment_view!
    after_audits  = Audited::Audit.where(auditable: hp_laser).count
    assert_equal before_audits, after_audits, "increment_view! must not create an audit record"
  end

  # ── FriendlyId ────────────────────────────────────────────────────────────

  test "generates a slug from the title" do
    l = Listing.create!(valid_attrs(title: "Unique Test Slug Listing Title Here"))
    assert_not_nil l.slug
    assert l.slug.include?("unique-test-slug")
  end

  test "slug regenerates when title changes" do
    l = Listing.create!(valid_attrs(title: "Original Title For Slug Generation Test"))
    old_slug = l.slug
    l.update!(title: "Completely Different Title For New Slug Generation")
    assert_not_equal old_slug, l.slug
  end

  # ── owned_by? ─────────────────────────────────────────────────────────────

  test "owned_by? returns true for the listing's user" do
    assert hp_laser.owned_by?(seller)
  end

  test "owned_by? returns false for a different user" do
    assert_not hp_laser.owned_by?(users(:buyer))
  end

  test "owned_by? returns false for nil" do
    assert_not hp_laser.owned_by?(nil)
  end

  # ── ListingSearch query object ────────────────────────────────────────────

  test "ListingSearch with no params returns all published kept listings" do
    results = ListingSearch.new.results
    assert results.all?(&:status_published?)
  end

  test "ListingSearch filters by listing_type" do
    results = ListingSearch.new(type: "sale").results
    assert results.all?(&:listing_type_sale?)
  end

  test "ListingSearch filters by max price" do
    results = ListingSearch.new(price_max: "40000").results
    assert results.all? { |l| l.price <= 40_000 }
  end

  test "ListingSearch filters by min price" do
    results = ListingSearch.new(price_min: "36000").results
    assert results.all? { |l| l.price >= 36_000 }
  end

  test "ListingSearch default sort_key is recent" do
    assert_equal "recent", ListingSearch.new.sort_key
  end

  test "ListingSearch respects valid sort param" do
    assert_equal "price_asc", ListingSearch.new(sort: "price_asc").sort_key
  end

  test "ListingSearch falls back to default for unknown sort" do
    assert_equal "recent", ListingSearch.new(sort: "invalid_sort").sort_key
  end
end
