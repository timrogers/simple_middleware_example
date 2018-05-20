require "rails_helper"

RSpec.describe Middleware::AuthorizationHeader do
  let(:instance) { described_class.new(next_middleware) }
  let(:next_middleware) { double(call: true) }

  let(:state) { Immutable::Hash.new(request: request) }
  let(:request) do
    instance_double(ActionDispatch::Request, headers: headers)
  end

  context "with no Authorization header" do
    let(:headers) { {} }

    it "renders an error" do
      expect(instance.call(state)).to eq([
        401,
        { "Content-Type" => "application/json" },
        "{\"errors\":[\"Missing access token\"]}"
      ])
    end
  end

  context "with an invalid Authorization header" do
    let(:headers) { { "HTTP_AUTHORIZATION" => "foo bar" } }

    it "renders an error" do
      expect(instance.call(state)).to eq([
        401,
        { "Content-Type" => "application/json" },
        "{\"errors\":[\"Missing access token\"]}"
      ])
    end

    it "doesn't call the next middleware" do
      expect(next_middleware).to_not receive(:call)
    end
  end

  context "with a correctly-structured Authorization headr" do
    let(:headers) { { "HTTP_AUTHORIZATION" => "Bearer your_access_token" } }

    it "calls the next middleware, passing on the access token" do
      expect(next_middleware).to receive(:call).
        with(Immutable::Hash.new(request: request,
                                 access_token: "your_access_token"))

      instance.call(state)
    end
  end
end
