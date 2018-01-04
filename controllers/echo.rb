class Echo < AbstractController
  def get(env)
    {
      body: env.to_s
    }
  end
end
