# frozen_string_literal: true

module Api
  # Serves the canonical OpenAPI spec for test_generator over HTTP.
  #
  # Public endpoint — no BasicAuth. The auth bypass is declared in
  # ApplicationController via the `unless:` lambda on
  # `http_basic_authenticate_with` (any path starting with `/api/openapi`).
  #
  # Spec source is `docs/openapi.yml` (hand-maintained, the canonical spec).
  # Once rswag-generated specs cover every endpoint (see
  # `spec/swagger_helper.rb` — "rswag-generated specs will incrementally
  # replace it"), this controller should switch to `swagger/v1/openapi.yaml`.
  #
  # Intentionally inherits from ApplicationController directly rather than
  # Api::BaseController so we can serve YAML/JSON without the
  # `request.format = :json` forcing and the JSON-specific rescue handlers
  # that Api::BaseController adds.
  class DocsController < ApplicationController
    SPEC_PATH = Rails.root.join('docs/openapi.yml')

    # Cache the parsed spec in memory — it's a fixed file read at boot time
    # in production. Avoids disk IO on every request.
    def self.spec
      @spec ||= YAML.safe_load(File.read(SPEC_PATH), aliases: true)
    end

    def openapi
      # Five-minute public cache so external tools (Postman import,
      # openapi-generator, Swagger UI) don't hammer the endpoint.
      response.set_header('Cache-Control', 'public, max-age=300')

      case params[:format].to_s
      when 'json'
        render json: self.class.spec
      else # 'yaml', 'yml', or default
        render plain: self.class.spec.to_yaml, content_type: 'application/yaml'
      end
    end
  end
end
