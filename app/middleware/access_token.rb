class Middleware::AccessToken < SimpleMiddleware::Middleware
  def call(state)
    user = User.find_by(access_token: state[:access_token])

    return invalid_access_token_error unless user.present?

    next_middleware.call(state.put(:user, user))
  end

  private

  def invalid_access_token_error
    render status: 401,
           headers: { "Content-Type" => "application/json" },
           body: JSON.generate(errors: [I18n.t("errors.invalid_access_token")])
  end
end
