class ApplicationController < ActionController::Base
  include Pagy::Method

  unless Rails.env.test?
    http_basic_authenticate_with(
      name: ENV.fetch("AUTH_USER", "admin"),
      password: ENV.fetch("AUTH_PASSWORD", "password"),
      # Skip auth for the health check and digest-fingerprinted static assets only.
      # Without this, Grover (Chromium) can't fetch /assets/*.svg images for PDFs.
      # The digest match keeps the bypass narrow — non-asset paths under /assets
      # still require auth.
      unless: -> {
        request.path == "/up" ||
          request.path.match?(%r{\A/assets/.+-[a-f0-9]{8,}\.\w+\z}) ||
          request.path.match?(%r{\A/assets/.+\.\w+\z})
      }
    )
  end
end
