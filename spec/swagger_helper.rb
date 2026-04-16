# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  # Output to swagger/ (rswag default). The canonical hand-maintained spec
  # currently lives at docs/openapi.yml; rswag-generated specs will
  # incrementally replace it as endpoints get request-spec coverage.
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/openapi.yaml' => {
      openapi: '3.0.3',
      info: {
        title: 'test_generator API',
        description: 'Exam and question generation API for self-testing',
        version: '1.0.0'
      },
      servers: [
        { url: 'https://selftesting.louisraymond.com' }
      ],
      components: {
        securitySchemes: {
          basicAuth: { type: :http, scheme: :basic }
        }
      },
      # NB: global `security` intentionally omitted so request specs don't
      # demand an Authorization header in test env (HTTP Basic Auth is
      # disabled in test — see ApplicationController). The exported spec
      # still documents basicAuth via components; per-endpoint security
      # blocks can be added to individual paths as needed.
      paths: {}
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
