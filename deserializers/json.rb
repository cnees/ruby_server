require 'json'

class Json < AbstractDeserializer
  def parse(body)
    JSON.parse(body)
  end
end
