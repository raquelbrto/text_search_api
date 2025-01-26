require "elasticsearch"

ES ||= Elasticsearch::Client.new(
  url: ENV["ES_URL"],
  request_timeout: ENV["ES_TIMEOUT"].to_i
)
