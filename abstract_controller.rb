class AbstractController

  def get(env)
    http_method_not_allowed
  end

  def head(env)
    http_method_not_allowed
  end

  def post(env)
    http_method_not_allowed
  end

  def put(env)
    http_method_not_allowed
  end

  def delete(env)
    http_method_not_allowed
  end

  def trace(env)
    http_method_not_allowed
  end

  def connect(env)
    http_method_not_allowed
  end

  def patch(env)
    http_method_not_allowed
  end

  def options(env)
    { status: 200, headers: {'Allowed' => allowed} }
  end

  private

  def http_method_not_allowed
    { status: 405, headers: {'Allowed' => allowed} }
  end

  def allowed
    http_verbs = %i[get head post put delete trace connect patch options]
    x = self.class.instance_methods(false).
      &(http_verbs). # union
      map(&:to_s).
      map(&:upcase).
      join(', ')
    x
  end
end
