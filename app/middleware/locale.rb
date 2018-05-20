class Middleware::Locale < SimpleMiddleware::Middleware
  def call(state)
    I18n.with_locale(state[:request].headers["Accept-Language"]) do
      next_middleware.call(state)
    end
  end
end
