# frozen_string_literal: true

class MockRequest
  Response = Struct.new(:body, :response_code) do
    def initialize(body, response_code: 200)
      super(body, response_code)
    end
    def success?
      return true
    end
  end

  def initialize(filename)
    self.response = 
      Response.new(
        File.read(
          Rails.root.join("spec", "fixtures", filename)
        )
      )
  end

  public

  attr_accessor :response
end
