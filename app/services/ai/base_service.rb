module Ai
  class BaseService
    MODEL   = "claude-haiku-4-5-20251001"
    TIMEOUT = 30

    private

    def client
      @client ||= Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY"))
    end

    def chat(system_prompt, user_message, max_tokens: 1024)
      response = client.messages.create(
        model:      MODEL,
        max_tokens: max_tokens,
        system:     system_prompt,
        messages:   [ { role: "user", content: user_message } ]
      )
      response.content.first.text
    rescue => e
      Rails.logger.error("[AI] #{self.class.name} error: #{e.message}")
      nil
    end

    def api_configured?
      ENV["ANTHROPIC_API_KEY"].present?
    end
  end
end
