require "test_helper"

class Ai::ListingDescriptionServiceTest < ActiveSupport::TestCase
  SAMPLE_ATTRS = {
    title:          "HP LaserJet Pro M404n",
    category:       "Printers",
    brand:          "HP",
    condition:      "used",
    listing_type:   "sale",
    printer_models: "HP LaserJet Pro series",
    price:          45_000,
    currency:       "PKR"
  }.freeze

  test "returns nil when ANTHROPIC_API_KEY is not set" do
    with_env("ANTHROPIC_API_KEY" => nil) do
      assert_nil Ai::ListingDescriptionService.call(SAMPLE_ATTRS)
    end
  end

  test "returns a string description when API responds successfully" do
    stub_text    = "A well-maintained HP LaserJet Pro M404n available for immediate purchase."
    fake_content = Struct.new(:text).new(stub_text)
    fake_resp    = Struct.new(:content).new([ fake_content ])
    fake_msgs    = Object.new.tap { |o| o.define_singleton_method(:create) { |**_| fake_resp } }
    fake_client  = Object.new.tap { |o| o.define_singleton_method(:messages) { fake_msgs } }

    with_env("ANTHROPIC_API_KEY" => "sk-ant-test") do
      service = Ai::ListingDescriptionService.new(SAMPLE_ATTRS)
      service.send(:with_client, fake_client) do
        assert_equal stub_text, service.call
      end
    end
  end

  test "returns nil when API raises an error" do
    fake_msgs   = Object.new.tap { |o| o.define_singleton_method(:create) { |**_| raise "conn error" } }
    fake_client = Object.new.tap { |o| o.define_singleton_method(:messages) { fake_msgs } }

    with_env("ANTHROPIC_API_KEY" => "sk-ant-test") do
      service = Ai::ListingDescriptionService.new(SAMPLE_ATTRS)
      service.send(:with_client, fake_client) do
        assert_nil service.call
      end
    end
  end
end
