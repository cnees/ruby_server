class Echo < AbstractController
  def get(body, env)
    request_method = env['REQUEST_METHOD']
    request_uri = env['REQUEST_URI']
    http_version = env['HTTP_VERSION']

    start_line = "#{request_method} #{request_uri} #{http_version}"

    headers = env.
      select{|key, value| key.start_with?('HTTP_') && key != 'HTTP_VERSION' }.
      map{|key, value| "#{key.split("_")[1..-1].map(&:capitalize).join('-')}: #{value}"}

    request_body = "\n" + body.to_s

    {
      headers: {'Content-Type' => 'text/plain; charset=utf-8'}.freeze,
      body: [start_line, headers, request_body].flatten.join("\n")
    }
  end

  alias_method :post, :get
  alias_method :delete, :get
  alias_method :put, :get
  alias_method :patch, :get
  alias_method :trace, :get
  alias_method :connect, :get
  alias_method :options, :get

end
