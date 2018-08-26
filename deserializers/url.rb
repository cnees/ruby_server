require 'uri'

class Url < AbstractDeserializer
  def parse(body)
    URI.decode_www_form(body).to_h
  end
end
