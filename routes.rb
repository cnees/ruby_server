require 'uri'

module Routes
  def self.routes
    build_default_routes(%w[
      /echo
      /hello
    ]).merge({
      "" => "/echo",
      "/we/love/our/users" => "/pander/to/users"
    })
  end

  private

  def self.build_default_routes(paths)
    paths.collect{|r| [r, r]}.to_h
  end
end
