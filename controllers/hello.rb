class Hello < AbstractController
  def get(env)
    {
      body: "Hello, Ben"
    }
  end
end
