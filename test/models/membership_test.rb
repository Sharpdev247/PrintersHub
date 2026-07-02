require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  def seller        = users(:seller)
  def buyer         = users(:buyer)
  def seller_account = accounts(:seller_account)
  def buyer_account  = accounts(:buyer_account)
  def owner_membership = memberships(:seller_owner)

  # ── Validity ──────────────────────────────────────────────────────────────

  test "fixture owner membership is valid" do
    assert owner_membership.valid?
  end

  test "invalid without role" do
    m = Membership.new(account: buyer_account, user: seller, role: nil)
    assert_not m.valid?
    assert m.errors[:role].any?
  end

  test "duplicate user+account membership is invalid" do
    m = Membership.new(account: seller_account, user: seller, role: :admin)
    assert_not m.valid?
    assert m.errors[:user_id].any?
  end

  test "allows same user in different accounts" do
    m = Membership.new(account: buyer_account, user: seller, role: :manager)
    assert m.valid?, m.errors.full_messages.inspect
  end

  # ── Roles ─────────────────────────────────────────────────────────────────

  test "role enum has expected keys" do
    %w[owner admin manager sales technician warehouse_staff accountant].each do |r|
      assert Membership.roles.key?(r), "missing role: #{r}"
    end
  end

  test "role_owner? returns true for owner" do
    assert owner_membership.role_owner?
  end

  # ── Last-owner guard ───────────────────────────────────────────────────────

  test "cannot discard the last owner" do
    owner_membership.discard
    assert_not owner_membership.valid?
    assert owner_membership.errors[:base].any?
  end

  test "can discard a non-owner member" do
    m = Membership.create!(account: seller_account, user: buyer, role: :admin)
    m.discard!
    assert m.discarded?
  end

  # ── display_title ─────────────────────────────────────────────────────────

  test "display_title returns role humanized when title is blank" do
    assert_equal "Owner", owner_membership.display_title
  end
end
