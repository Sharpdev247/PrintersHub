require "test_helper"

class Ai::PriceSuggestionServiceTest < ActiveSupport::TestCase
  SAMPLE_ATTRS = { title: "HP Toner Cartridge", brand: "HP", condition: "new" }.freeze

  test "returns nil when API key is absent" do
    with_env("ANTHROPIC_API_KEY" => nil) do
      assert_nil Ai::PriceSuggestionService.call(SAMPLE_ATTRS, comparable_listings: [])
    end
  end

  test "returns a hash with min/max/suggested when API responds" do
    stub_json = '{"min": 2000, "max": 3500, "suggested": 2800, "rationale": "Based on 3 recent sales."}'

    with_env("ANTHROPIC_API_KEY" => "sk-ant-test") do
      service = Ai::PriceSuggestionService.new(SAMPLE_ATTRS, [])
      service.stub(:chat, stub_json) do
        result = service.call
        assert_equal 2000, result[:min]
        assert_equal 3500, result[:max]
        assert_equal 2800, result[:suggested]
        assert_includes result[:rationale], "recent"
      end
    end
  end

  test "returns nil when API returns malformed JSON" do
    with_env("ANTHROPIC_API_KEY" => "sk-ant-test") do
      service = Ai::PriceSuggestionService.new(SAMPLE_ATTRS, [])
      service.stub(:chat, "not valid json at all") do
        assert_nil service.call
      end
    end
  end
end
