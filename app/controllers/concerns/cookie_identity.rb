module CookieIdentity
  extend ActiveSupport::Concern

  included do
    before_action :ensure_cookie_id
  end

  def current_cookie_id
    cookies.signed[:user_token]
  end

  private

  def ensure_cookie_id
    return if cookies.signed[:user_token].present?
    cookies.signed[:user_token] = {
      value: SecureRandom.urlsafe_base64(24),
      expires: 1.year.from_now,
      httponly: true,
      same_site: :lax
    }
  end
end
