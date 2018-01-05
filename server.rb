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
  begin
    response = fetch_response(env, load_controller!(env))
  rescue NoRouteError => e
    log_error(e)
    response = { status: 404 }
  rescue StandardError => e
    log_error(e)
    response = { status: 500 }
  end

  [
    response&.[](:status) || 200,
    DEFAULT_HEADERS.merge(response&.[](:headers) || {}),
    response&.[](:body) ? [response[:body]] : []
  ]
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

def load_controller!(env)
  request_path = URI(env['REQUEST_URI']).path.chomp('/')
  raise NoRouteError unless Routes.routes.include?(request_path)
  internal_path = Routes.routes[request_path]
  require_relative "./controllers#{internal_path}.rb"
  klass(internal_path).new
end

def klass(path)
  Object.const_get(path.split('/').last.split('_').map(&:capitalize).join)
end

def log_error(e)
  STDERR.puts e, e.backtrace
end

Rack::Handler::WEBrick.run Proc.new{|env| handle_request(env)}
