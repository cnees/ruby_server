require 'rack'
require 'uri'
require './routes.rb'


DEFAULT_HEADER = {'Content-Type' => 'text/html; charset=utf-8'}.freeze


def request_handler(env)
  path = URI(env['REQUEST_URI']).path.chomp('/')

  begin
    require_handler(path)
    response = get_response(env)
  rescue NoMethodError, LoadError
    return [
      404,
      DEFAULT_HEADER,
      ["404: Page not found"]
    ]
  end

  [
    response&.[](:status) || 200,
    response&.[](:headers) || DEFAULT_HEADER,
    response&.[:body] ? [response[:body]] : []
  ]
end


def require_handler(path)
  handler_file_path = if Routes.routes.include?(path)
    Routes.routes[path]
  else
    path
  end

  require_relative "./controllers#{handler_file_path}.rb"
end

def get_response(env)

  begin
    request_method = env['REQUEST_METHOD'].downcase
    response = case request_method
      when 'post','pfffbt','duuuuuuuude','put'
        send(request_method, env)
      else
        get(env)
      end
  rescue NoMethodError
    get(env)
  rescue NoMethodError
    raise "No get method for controller"
  end

end

Rack::Handler::WEBrick.run Proc.new{|env| request_handler(env)}
