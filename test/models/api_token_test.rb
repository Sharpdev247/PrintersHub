require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  def seller        = users(:seller)
  def seller_account = accounts(:seller_account)

  def generate_token(overrides = {})
    ApiToken.generate!(
      account:    seller_account,
      user:       seller,
      name:       "Test token #{SecureRandom.hex(4)}",
      scopes:     ["read:listings"],
      expires_at: 30.days.from_now,
      **overrides
    )
  end

  # ── generate! ────────────────────────────────────────────────────────────

  test "generate! returns [token_record, raw_token]" do
    token, raw = generate_token
    assert_instance_of ApiToken, token
    assert token.persisted?
    assert raw.start_with?("phb_")
  end

  test "raw token is not stored in database" do
    token, raw = generate_token
    assert_not_equal raw, token.token_digest
  end

  test "display_token masks most of the token" do
    token, _raw = generate_token
    assert token.display_token.include?("••••••••")
  end

  # ── authenticate ─────────────────────────────────────────────────────────

  test "authenticate returns the token for a valid raw token" do
    token, raw = generate_token
    found = ApiToken.authenticate(raw)
    assert_equal token.id, found.id
  end

  test "authenticate returns nil for a wrong token" do
    assert_nil ApiToken.authenticate("phb_wrongtoken")
  end

  test "authenticate returns nil for a blank value" do
    assert_nil ApiToken.authenticate(nil)
    assert_nil ApiToken.authenticate("")
  end

  test "authenticate updates last_used_at" do
    token, raw = generate_token
    assert_nil token.last_used_at
    ApiToken.authenticate(raw)
    assert_not_nil token.reload.last_used_at
  end

  # ── active? / expired? / revoked? ────────────────────────────────────────

  test "token is active when not revoked and not expired" do
    token, _raw = generate_token
    assert token.active?
  end

  test "revoke! marks the token revoked" do
    token, _raw = generate_token
    token.revoke!
    assert token.revoked?
    assert_not token.active?
  end

  test "authenticate returns nil for revoked token" do
    token, raw = generate_token
    token.revoke!
    assert_nil ApiToken.authenticate(raw)
  end

  test "expired token is not returned by active scope" do
    token, _raw = ApiToken.generate!(
      account:    seller_account,
      user:       seller,
      name:       "expired",
      scopes:     ["read:listings"],
      expires_at: 1.day.from_now
    )
    token.update_column(:expires_at, 1.day.ago)
    assert_not ApiToken.active.include?(token)
  end

  # ── has_scope? ────────────────────────────────────────────────────────────

  test "has_scope? returns true when scope is present" do
    token, _raw = generate_token(scopes: ["read:listings", "write:orders"])
    assert token.has_scope?("read:listings")
    assert token.has_scope?("write:orders")
  end

  test "has_scope? returns false when scope is absent" do
    token, _raw = generate_token(scopes: ["read:listings"])
    assert_not token.has_scope?("write:listings")
  end

  test "admin scope grants all scopes" do
    token, _raw = generate_token(scopes: ["admin"])
    assert token.has_scope?("write:inventory")
    assert token.has_scope?("read:analytics")
  end

  # ── Validations ───────────────────────────────────────────────────────────

  test "invalid with unknown scope" do
    token = ApiToken.new(
      account:    seller_account,
      user:       seller,
      name:       "bad",
      token_digest: "x",
      prefix:     "phb_test",
      token_type: "personal",
      scopes:     ["destroy:everything"],
      expires_at: 7.days.from_now
    )
    assert_not token.valid?
    assert token.errors[:scopes].any?
  end

  test "invalid with expiry in the past" do
    token = ApiToken.new(
      account:    seller_account,
      user:       seller,
      name:       "bad",
      token_digest: "y",
      prefix:     "phb_test2",
      token_type: "personal",
      scopes:     ["read:listings"],
      expires_at: 1.day.ago
    )
    assert_not token.valid?
    assert token.errors[:expires_at].any?
  end
end
