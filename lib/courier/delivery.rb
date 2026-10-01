require "logger"
require "net/http"
require "uri"

module Courier
  # Posts one webhook and reports whether the receiver accepted it.
  class Delivery
    TIMEOUT = 10
    MAX_ATTEMPTS = 12

    def initialize(signer, logger: Logger.new($stdout))
      @signer = signer
      @logger = logger
    end

    def deliver(endpoint, event, body)
      uri = URI(endpoint)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Courier-Event"] = event
      request["Courier-Signature"] = @signer.header(body)
      request.body = body

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                                     open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
        http.request(request)
      end
      @logger.info("delivered #{event} to #{uri.host} status=#{response.code}")
      response.code.to_i.between?(200, 299)
    end

    # Delivers with exponential backoff (2s, 4s, 8s, ...) until the receiver accepts or
    # MAX_ATTEMPTS is reached. Returns whether it was eventually accepted.
    def deliver_with_retries(endpoint, event, body)
      attempt = 0
      begin
        attempt += 1
        return true if deliver(endpoint, event, body)

        raise "receiver rejected #{event}"
      rescue StandardError => e
        @logger.warn("delivery failed attempt=#{attempt} endpoint=#{endpoint} error=#{e.message}")
        if attempt < MAX_ATTEMPTS
          sleep(2**attempt)
          retry
        end
        false
      end
    end
  end
end
