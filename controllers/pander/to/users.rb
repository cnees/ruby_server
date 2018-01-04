class Users < AbstractController
  def get(env)
    {
      body: "You're the best."
    }
  end
end
