require 'uri'

module Routes
  def self.routes
    {
      "" => "/echo",
      "/we/love/our/users" => "/pander/to/users"
    }
  end
end
