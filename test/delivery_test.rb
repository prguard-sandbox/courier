require "minitest/autorun"
require "webmock/minitest"
require_relative "../lib/courier"

class DeliveryTest < Minitest::Test
  def setup
    @delivery = Courier::Delivery.new(Courier::Signer.new("s3cr3t-for-tests"), logger: Logger.new(nil))
  end

  def test_a_2xx_answer_is_a_successful_delivery
    stub_request(:post, "https://hooks.example.com/in").to_return(status: 204)
    assert @delivery.deliver("https://hooks.example.com/in", "order.paid", "{}")
  end

  def test_a_5xx_answer_is_a_failed_delivery
    stub_request(:post, "https://hooks.example.com/in").to_return(status: 503)
    refute @delivery.deliver("https://hooks.example.com/in", "order.paid", "{}")
  end
end
