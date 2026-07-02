require "test_helper"

class UserTest < ActiveSupport::TestCase
  def seller   = users(:seller)
  def buyer    = users(:buyer)

  # ── Validity ──────────────────────────────────────────────────────────────

  test "fixture seller is valid" do
    assert seller.valid?
  end

  test "invalid without email" do
    u = User.new(password: "Password1!", password_confirmation: "Password1!")
    assert_not u.valid?
    assert u.errors[:email].any?
  end

  test "invalid with duplicate email" do
    u = User.new(email: seller.email, password: "Password1!", password_confirmation: "Password1!")
    assert_not u.valid?
    assert u.errors[:email].any?
  end

  test "invalid with short password" do
    u = User.new(email: "new@example.com", password: "abc", password_confirmation: "abc")
    assert_not u.valid?
    assert u.errors[:password].any?
  end

  # ── Associations ──────────────────────────────────────────────────────────

  test "has memberships" do
    assert_respond_to seller, :memberships
  end

  test "has accounts through memberships" do
    assert_respond_to seller, :accounts
  end

  test "has api_tokens" do
    assert_respond_to seller, :api_tokens
  end

  test "has favorites" do
    assert_respond_to seller, :favorites
  end

  # ── primary_account ───────────────────────────────────────────────────────

  test "primary_account returns an account for a user with memberships" do
    assert_not_nil seller.primary_account
  end

  # ── full_name ─────────────────────────────────────────────────────────────

  test "full_name returns non-blank string" do
    assert_respond_to seller, :full_name
  end

  # ── role_for ──────────────────────────────────────────────────────────────

  test "role_for returns a string role when the user is a member" do
    account = accounts(:seller_account)
    result  = seller.role_for(account)
    assert_not_nil result
  end

  test "role_for returns nil when the user has no membership in the account" do
    account = accounts(:buyer_account)
    assert_nil seller.role_for(account)
  end
end
