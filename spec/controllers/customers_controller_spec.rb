require "rails_helper"

RSpec.describe CustomersController, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  describe "#create" do
    subject(:make_request) { post :create, params: params, format: :json }

    let(:params) do
      {
        data: {
          email: "alice@gocardless.com",
          iban: "GB29NWBK60161331926819"
        }
      }
    end

    context "with no access token" do
      it "responds with a 401" do
        make_request
        expect(response).to be_unauthorized

        parsed_response = JSON.parse(response.body)
        expect(parsed_response["errors"]).to eq(["Access token not provided"])
      end

      context "requesting a language other than English" do
        before { request.headers["Accept-Language"] = "uk" }

        it "responds with a 401, with the error translated" do
          make_request
          expect(response).to be_unauthorized

          parsed_response = JSON.parse(response.body)
          expect(parsed_response["errors"]).to eq(["Access token not provided"])
        end
      end
    end

    context "with an invalid access token" do
      before { request.headers["Authorization"] = "Bearer fake_access_token" }

      it "responds with a 401" do
        make_request
        expect(response).to be_unauthorized

        parsed_response = JSON.parse(response.body)
        expect(parsed_response["errors"]).to eq(["Invalid access token"])
      end
    end

    context "with a valid access token" do
      before { request.headers["Authorization"] = "Bearer #{user.access_token}" }

      it "renders back the created customer" do
        expect { make_request }.to change(user.customers, :count).by(1)
        expect(response).to be_successful

        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to include("email" => "alice@gocardless.com",
                                           "iban" => "GB29NWBK60161331926819")
      end

      context "with invalid parameters" do
        let(:params) { { data: { email: "alice@gocardless.com" } } }

        it "renders back the validation errors in the requested language" do
          request.headers["Accept-Language"] = "uk"

          expect { make_request }.to_not change(user.customers, :count)
          expect(response).to be_unprocessable

          parsed_response = JSON.parse(response.body)
          expect(parsed_response["errors"]).to eq(["IBAN не може бути пустим"])
        end
      end
    end
  end
end
