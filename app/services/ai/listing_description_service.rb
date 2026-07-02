module Ai
  # Generates a compelling marketplace listing description from structured attributes.
  # Returns nil when the API is not configured or the call fails — callers must handle gracefully.
  class ListingDescriptionService < BaseService
    SYSTEM_PROMPT = <<~PROMPT.freeze
      You are a copywriter for PrintersHub, a B2B marketplace for printer parts, equipment, and services.
      Write concise, professional listing descriptions for sellers.
      Focus on technical accuracy, condition, compatibility, and value.
      Avoid fluff. Use 2–4 short paragraphs. No markdown headers. Plain text only.
    PROMPT

    def self.call(listing_attrs)
      new(listing_attrs).call
    end

    def initialize(listing_attrs)
      @attrs = listing_attrs
    end

    def call
      return nil unless api_configured?

      chat(SYSTEM_PROMPT, user_message, max_tokens: 512)
    end

    private

    def user_message
      parts = []
      parts << "Title: #{@attrs[:title]}"                           if @attrs[:title].present?
      parts << "Category: #{@attrs[:category]}"                     if @attrs[:category].present?
      parts << "Brand: #{@attrs[:brand]}"                           if @attrs[:brand].present?
      parts << "Condition: #{@attrs[:condition]}"                   if @attrs[:condition].present?
      parts << "Listing type: #{@attrs[:listing_type]}"             if @attrs[:listing_type].present?
      parts << "Compatible models: #{@attrs[:printer_models]}"      if @attrs[:printer_models].present?
      parts << "Price: #{@attrs[:price]} #{@attrs[:currency]}"      if @attrs[:price].present?
      parts << "Additional notes: #{@attrs[:notes]}"                if @attrs[:notes].present?

      "Generate a listing description for this item:\n\n#{parts.join("\n")}"
    end
  end
end
