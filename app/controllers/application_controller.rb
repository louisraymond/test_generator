class ApplicationController < ActionController::Base
  include Pagy::Method

  http_basic_authenticate_with(
    name: ENV.fetch("AUTH_USER", "admin"),
    password: ENV.fetch("AUTH_PASSWORD", "password"),
    unless: -> { request.path == "/up" }
  )
end
