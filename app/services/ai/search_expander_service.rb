module Ai
  # Expands a natural-language search query into structured filters + keywords.
  # Used to power the "AI search" feature on the public listings page.
  # Returns nil on failure so callers fall back to plain text search.
  class SearchExpanderService < BaseService
    SYSTEM_PROMPT = <<~PROMPT.freeze
      You are a search assistant for PrintersHub, a B2B marketplace for printer parts and equipment.
      Given a natural-language search query, extract structured filters and clean keywords.
      Reply with JSON only:
      {
        "keywords": "STRING — clean search terms for full-text search",
        "listing_type": "sale|rental|service|null",
        "condition": "new|used|refurbished|for_parts|null",
        "category_hint": "STRING or null — e.g. 'toner cartridges', 'drum units', 'fusers'",
        "brand_hint": "STRING or null",
        "price_max": NUMBER_OR_NULL,
        "intent_summary": "STRING — one sentence describing what the user wants"
      }
      Use null (not the string "null") for fields you cannot confidently extract.
    PROMPT

    def self.call(query)
      new(query).call
    end

    def initialize(query)
      @query = query
    end

    def call
      return nil unless api_configured?
      return nil if @query.blank?

      raw = chat(SYSTEM_PROMPT, "Search query: #{@query}", max_tokens: 300)
      return nil if raw.nil?

      JSON.parse(raw.match(/\{.*\}/m)&.to_s || "", symbolize_names: true)
    rescue JSON::ParserError
      nil
    end
  end
end
