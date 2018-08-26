class AbstractDeserializer
  def parse
    raise NoMethodError # must be overridden
  end
end
