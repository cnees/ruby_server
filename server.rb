require 'pry'
require 'rack'
require 'rack/handler/puma'
require 'uri'
require './routes.rb'
require './abstract_controller.rb'
require './deserializers/abstract_deserializer.rb'

DEFAULT_HEADERS = {
  'Content-Type' => 'text/html; charset=utf-8',
  'Content-Language' => 'en-US'
}.freeze
HTTP_VERBS = %w[get head post delete put patch trace connect options]
CONTENT_TYPE_DESERIALIZERS = {
  'application/json' => 'json',
  'text/csv' => 'csv',
  'application/x-www-form-urlencoded' => 'url',
}.freeze
class NoRouteError < StandardError; end
class UnsupportedHttpVerbError < StandardError; end
class BadRequest < StandardError; end

def handle_request(env)
  begin
    request_method = env['REQUEST_METHOD'].downcase
    raise UnsupportedHttpVerbError unless HTTP_VERBS.include?(request_method)
    response = load_controller!(env).send(request_method, parse_body(env), env)
  rescue UnsupportedHttpVerbError => e
    log_error(e)
    response = { status: 400, body: "400: Bad request—Unsupported HTTP verb" }
  rescue BadRequest => e
    log_error(e)
    response = { status: 400 }
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

def load_controller!(env)
  request_path = URI(env['REQUEST_URI']).path.chomp('/')
  raise NoRouteError unless Routes.routes.include?(request_path)
  internal_path = Routes.routes[request_path]
  require_relative "./controllers#{internal_path}.rb"
  klass(internal_path).new
end

def parse_body(env)
  content_type = env['CONTENT_TYPE']&.downcase
  if CONTENT_TYPE_DESERIALIZERS.has_key?(content_type)
    begin
      deserializer = CONTENT_TYPE_DESERIALIZERS[content_type]
      require_relative "./deserializers/#{deserializer}.rb"
      return klass(deserializer).new.send('parse', env['rack.input'].read)
    rescue StandardError => e
      log_error(e)
      raise BadRequest
    end
  else
    return env['rack.input'].read
  end
end

def klass(path)
  Object.const_get(path.split('/').last.split('_').map(&:capitalize).join)
end

def log_error(e)
  STDERR.puts e, e.backtrace
end

Rack::Handler::Puma.run Proc.new{|env| handle_request(env)}
