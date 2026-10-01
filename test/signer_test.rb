require "minitest/autorun"
require_relative "../lib/courier/signer"

class SignerTest < Minitest::Test
  def test_header_carries_timestamp_and_hmac
    header = Courier::Signer.new("s3cr3t-for-tests").header("{}", timestamp: 1_700_000_000)
    assert_match(/\At=1700000000,v1=\h{64}\z/, header)
  end

  def test_rejects_an_empty_secret
    assert_raises(ArgumentError) { Courier::Signer.new("") }
  end
end
