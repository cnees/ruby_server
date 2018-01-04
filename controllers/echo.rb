class Echo < AbstractController
  def get(env)
    request_method = env['REQUEST_METHOD']
    request_uri = env['REQUEST_URI']
    http_version = env['HTTP_VERSION']

    start_line = "#{request_method} #{request_uri} #{http_version}"

    headers = env.
      select{|key, value| key.start_with?('HTTP_') && key != 'HTTP_VERSION' }.
      map{|key, value| "#{key.split("_")[1..-1].join('-')}: #{value}"}

    request_body = "\n" + env['rack.input'].read

    {
      headers: {'Content-Type' => 'text/plain; charset=utf-8'}.freeze,
      body: [start_line, headers, request_body].flatten.join("\n")
    }
  end
end
