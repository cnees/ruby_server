require 'rack'
require 'uri'
require './routes.rb'
require './abstract_controller.rb'

DEFAULT_HEADERS = {
  'Content-Type' => 'text/html; charset=utf-8',
  'Content-Language' => 'en-US'
}.freeze

class NoRouteError < StandardError; end

def handle_request(env)
  request_path = URI(env['REQUEST_URI']).path.chomp('/')

  begin
    controller_path = controller_file_path(request_path)
    require_controller(controller_path)
    response = fetch_response(env, klass(controller_path).new)
  rescue NoRouteError => e
    STDERR.puts e, e.backtrace
    response = { status: 404 }
  rescue StandardError => e
    STDERR.puts e, e.backtrace
    response = { status: 500 }
  end

  [
    response&.[](:status) || 200,
    DEFAULT_HEADERS.merge(response&.[](:headers) || {}),
    response&.[](:body) ? [response[:body]] : []
  ]
end

def controller_file_path(path)
  if Routes.routes.include?(path)
    Routes.routes[path]
  else
    raise NoRouteError
  end
end

def require_controller(path)
  require_relative "./controllers#{path}.rb"
end

def fetch_response(env, controller)
  request_method = env['REQUEST_METHOD'].downcase
  valid_http_methods = %w[get head post delete put patch trace connect options]
  if valid_http_methods.include?(request_method)
    controller.send(request_method, env)
  else
    controller.send("bad_request", env)
  end
end

def klass(path)
  Object.const_get(path.split('/').last.split('_').map(&:capitalize).join)
end

Rack::Handler::WEBrick.run Proc.new{|env| handle_request(env)}
