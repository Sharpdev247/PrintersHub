module Ai
  # Suggests a price range for a listing based on comparable sold listings in the account.
  # Falls back gracefully when AI is unavailable or no comparable data exists.
  class PriceSuggestionService < BaseService
    SYSTEM_PROMPT = <<~PROMPT.freeze
      You are a pricing analyst for PrintersHub, a B2B marketplace for printer parts and equipment.
      Given a new listing's attributes and recent comparable sold listings, suggest a competitive price range.
      Be concise. Reply with JSON only: {"min": NUMBER, "max": NUMBER, "suggested": NUMBER, "rationale": "STRING"}
      Numbers should be plain integers or decimals. No currency symbols in numbers.
    PROMPT

    def self.call(listing_attrs, comparable_listings: [])
      new(listing_attrs, comparable_listings).call
    end

    def initialize(listing_attrs, comparable_listings)
      @attrs       = listing_attrs
      @comparables = comparable_listings
    end

    def call
      return nil unless api_configured?

      raw = chat(SYSTEM_PROMPT, user_message, max_tokens: 256)
      return nil if raw.nil?

      JSON.parse(raw.match(/\{.*\}/m)&.to_s || "", symbolize_names: true)
    rescue JSON::ParserError
      nil
    end

    private

    def user_message
      parts = []
      parts << "New listing:"
      parts << "  Title: #{@attrs[:title]}"
      parts << "  Category: #{@attrs[:category]}"
      parts << "  Brand: #{@attrs[:brand]}"
      parts << "  Condition: #{@attrs[:condition]}"
      parts << "  Compatible models: #{@attrs[:printer_models]}" if @attrs[:printer_models].present?

      if @comparables.any?
        parts << "\nRecent comparable sold listings (title | condition | sold price):"
        @comparables.first(10).each do |c|
          parts << "  - #{c[:title]} | #{c[:condition]} | #{c[:price]} #{c[:currency]}"
        end
      else
        parts << "\nNo comparable sold listings available."
      end

      parts.join("\n")
    end
  end
end
