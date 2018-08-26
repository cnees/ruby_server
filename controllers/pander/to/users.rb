class Users < AbstractController
  def get(body, env)
    {
      body: "You're the best."
    }
  end
end
