class Hello < AbstractController
  def get(body, env)
    {
      body: "Hello, Ben"
    }
  end
end
