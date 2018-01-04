require 'rack'
require 'uri'
require './routes.rb'
require './abstract_controller.rb'


DEFAULT_HEADER = {'Content-Type' => 'text/html; charset=utf-8'}.freeze

class NoControllerError < StandardError; end

def handle_request(env)
  request_path = URI(env['REQUEST_URI']).path.chomp('/')

  begin
    controller_path = controller_file_path(request_path)
    require_controller(controller_path)
    response = fetch_response(env, klass(controller_path).new)
  rescue NoMethodError, LoadError, NoControllerError => e
    STDERR.puts e
    STDERR.puts e.backtrace
    return [ 404, DEFAULT_HEADERS, [] ]
  end

  [
    response&.[](:status) || 200,
    response&.[](:headers) || DEFAULT_HEADER,
    response&.[:body] ? [response[:body]] : []
  ]
end

def controller_file_path(path)
  if Routes.routes.include?(path)
    Routes.routes[path]
  else
    raise NoControllerError
  end
end

def require_controller(path)
  require_relative "./controllers#{path}.rb"
end

def fetch_response(env, controller)
  begin
    request_method = env['REQUEST_METHOD'].downcase
    response = case request_method
      when 'post','put','delete','trace','connect','patch','options'
        controller.send(request_method, env)
      else
        controller.get(env)
      end
  rescue NoMethodError
    controller.get(env)
  end
end

def klass(path)
  Object.const_get(path.split('/').last.split('_').map(&:capitalize).join)
end

Rack::Handler::WEBrick.run Proc.new{|env| handle_request(env)}
