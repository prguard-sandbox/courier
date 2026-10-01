require "openssl"

module Courier
  # Signs payloads so receivers can check they came from us and are fresh.
  class Signer
    def initialize(secret)
      raise ArgumentError, "signing secret is required" if secret.nil? || secret.empty?

      @secret = secret
    end

    def header(body, timestamp: Time.now.to_i)
      digest = OpenSSL::HMAC.hexdigest("SHA256", @secret, "#{timestamp}.#{body}")
      "t=#{timestamp},v1=#{digest}"
    end
  end
end
