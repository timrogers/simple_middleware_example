class Middleware::AuthorizationHeader < SimpleMiddleware::Middleware
  def call(state)
    header_value = state[:request].headers["HTTP_AUTHORIZATION"]

    return missing_access_token_error unless header_value.present?
    token_type, token = header_value.split(" ", 2)
    return missing_access_token_error unless token_type == "Bearer"

    next_middleware.call(state.put(:access_token, token))
  end

  private

  def missing_access_token_error
    render status: 401,
           headers: { "Content-Type" => "application/json" },
           body: JSON.generate(errors: [I18n.t("errors.missing_access_token")])
  end
end
