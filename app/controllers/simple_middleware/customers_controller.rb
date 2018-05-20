class SimpleMiddleware::CustomersController < ApplicationController
  class Create < SimpleMiddleware::Middleware
    def call(state)
      customer_params = build_customer_params(state)
      customer = Customer.new(customer_params)

      if customer.save
        render status: 201,
               headers: { "Content-Type" => "application/json" },
               body: customer.to_json
      else
        render status: 422,
               headers: { "Content-Type" => "application/json" },
               body: JSON.generate(errors: customer.errors.full_messages)
      end
    end

    private

    def build_customer_params(state)
      params = ActionController::Parameters.new(state[:request].params)

      params.require(:data).permit(:email, :iban).merge(user: state[:user])
    end
  end

  def create
    response = SimpleMiddleware.call(initial_state: { request: request },
                                     middlewares: [Middleware::Locale,
                                                   Middleware::AuthorizationHeader,
                                                   Middleware::AccessToken,
                                                   Create])

    render_rack_response(response)
  end

  private

  def render_rack_response(response)
    response[1].each do |header_name, header_value|
      self.response.headers[header_name] = header_value
    end

    render status: response.first,
           body: response.last
  end
end
