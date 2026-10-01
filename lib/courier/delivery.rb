require "logger"
require "net/http"
require "uri"

module Courier
  # Posts one webhook and reports whether the receiver accepted it.
  class Delivery
    TIMEOUT = 10

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
  end
end
