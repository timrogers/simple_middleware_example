class CustomersController < ApplicationController
  around_action :with_locale
  before_action :check_authorization_header
  before_action :check_access_token

  def create
    customer = Customer.new(customer_params.merge(user: @user))

    if customer.save
      render json: customer
    else
      render json: { errors: customer.errors.full_messages }, status: 422
    end
  end

  private

  def customer_params
    params.require(:data).permit(:email, :iban)
  end

  private

  def check_authorization_header
    header_value = request.headers["HTTP_AUTHORIZATION"]

    return missing_access_token_error unless header_value.present?
    token_type, token = header_value.split(" ", 2)
    return missing_access_token_error unless token_type == "Bearer"

    @access_token = token
  end

  def check_access_token
    @user = User.find_by(access_token: @access_token)

    return invalid_access_token_error unless @user.present?
  end

  def missing_access_token_error
    render json: { errors: ["Access token not provided"] },
          status: 401
  end

  def invalid_access_token_error
    render json: { errors: ["Invalid access token"] },
          status: 401
  end

  def with_locale
    I18n.with_locale(request.headers["HTTP_ACCEPT_LANGUAGE"]) do
      yield
    end
  end
end
