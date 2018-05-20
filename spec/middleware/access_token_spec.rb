require "rails_helper"

RSpec.describe Middleware::AccessToken do
  let(:instance) { described_class.new(next_middleware) }
  let(:next_middleware) { double(call: true) }

  let(:state) { Immutable::Hash.new(access_token: access_token) }

  context "with a non-existent access token" do
    let(:access_token) { "dummy_access_token" }

    it "renders an error" do
      expect(instance.call(state)).to eq([
        401,
        { "Content-Type" => "application/json" },
        "{\"errors\":[\"Invalid access token\"]}"
      ])
    end
  end

  context "with a valid access token" do
    let(:user) { FactoryBot.create(:user) }
    let(:access_token) { user.access_token }

    it "calls the next middleware, passing on the access token" do
      expect(next_middleware).to receive(:call).
        with(Immutable::Hash.new(access_token: access_token, user: user))

      instance.call(state)
    end
  end
end
