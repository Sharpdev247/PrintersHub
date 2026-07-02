require "test_helper"

class AccountTest < ActiveSupport::TestCase
  def seller_account = accounts(:seller_account)
  def buyer_account  = accounts(:buyer_account)

  def valid_attrs(overrides = {})
    {
      name:         "Test Account #{SecureRandom.hex(4)}",
      account_type: :individual,
      status:       :active
    }.merge(overrides)
  end

  # ── Validity ──────────────────────────────────────────────────────────────

  test "fixture seller_account is valid" do
    assert seller_account.valid?
  end

  test "invalid without name" do
    a = Account.new(valid_attrs(name: ""))
    assert_not a.valid?
    assert a.errors[:name].any?
  end

  test "invalid with name shorter than 2 characters" do
    a = Account.new(valid_attrs(name: "X"))
    assert_not a.valid?
    assert a.errors[:name].any?
  end

  test "invalid with malformed email" do
    a = Account.new(valid_attrs(email: "not-an-email"))
    assert_not a.valid?
    assert a.errors[:email].any?
  end

  test "valid with blank email (optional)" do
    a = Account.new(valid_attrs(email: ""))
    assert a.valid?, a.errors.full_messages.inspect
  end

  test "slug is generated from name" do
    a = Account.create!(valid_attrs(name: "Printers World Test Co #{SecureRandom.hex(4)}"))
    assert_not_nil a.slug
  end

  # ── Enums ─────────────────────────────────────────────────────────────────

  test "account_type enum has expected values" do
    %w[individual company dealer vendor enterprise].each do |t|
      assert Account.account_types.key?(t), "missing account_type: #{t}"
    end
  end

  test "status enum has expected values" do
    %w[active suspended closed].each do |s|
      assert Account.statuses.key?(s), "missing status: #{s}"
    end
  end

  # ── Soft delete ───────────────────────────────────────────────────────────

  test "discard sets discarded_at" do
    a = Account.create!(valid_attrs)
    a.discard!
    assert_not_nil a.reload.discarded_at
  end

  test "kept scope excludes discarded accounts" do
    a = Account.create!(valid_attrs)
    a.discard!
    assert_not Account.kept.include?(a)
  end

  # ── Associations ──────────────────────────────────────────────────────────

  test "has many memberships" do
    assert_respond_to seller_account, :memberships
  end

  test "has many users through memberships" do
    assert_respond_to seller_account, :users
  end

  test "has many listings" do
    assert_respond_to seller_account, :listings
  end
end
