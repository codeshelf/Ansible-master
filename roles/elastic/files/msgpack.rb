# encoding: utf-8
require "logstash/codecs/base"

class LogStash::Codecs::Msgpack < LogStash::Codecs::Base
  config_name "msgpack"

  milestone 1

  config :format, :validate => :string, :default => nil

  public
  def register
    require "msgpack"
  end

  public
  def decode(data)
    begin
      # Msgpack does not care about UTF-8
      event = LogStash::Event.new(MessagePack.unpack(data))

      # patch to fix timestamp type crash!
      event["@timestamp"] = Time.at(event["@timestamp_f"]).utc if event["@timestamp_f"].is_a? Float
      event.remove("@timestamp_f")

      event["tags"] ||= []
      if @format
        event["message"] ||= event.sprintf(@format)
      end
    rescue => e
      # Treat as plain text and try to do the best we can with it?
      @logger.warn("Trouble parsing msgpack input, falling back to plain text",
                   :input => data, :exception => e)
      event["message"] = data
      event["tags"] ||= []
      event["tags"] << "_msgpackparsefailure"
    end
    yield event
  end # def decode

  public
  def encode(event)
    # patch to fix timestamp type crash!
    event["@timestamp_f"] = event["@timestamp"].to_f
    event.remove("@timestamp")
    @on_event.call MessagePack.pack(event.to_hash)
  end # def encode

end # class LogStash::Codecs::Msgpack
