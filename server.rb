require 'rack'

def request_handler(env)
  return [200, {}, [env['REQUEST_URI']]]
end

Rack::Handler::WEBrick.run Proc.new{|env| request_handler(env)}
