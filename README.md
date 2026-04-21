# README

See docs/ONBOARDING.md for setup, architecture, and workflow details for Phase 1 of the exam generator.

## API

The OpenAPI 3.0.3 spec is served publicly (no auth required) at:

- `https://selftesting.louisraymond.com/api/openapi.yaml` (YAML)
- `https://selftesting.louisraymond.com/api/openapi.json` (JSON)
- `https://selftesting.louisraymond.com/api/docs` — browsable docs (Scalar UI)

The hand-maintained source lives at [`docs/openapi.yml`](docs/openapi.yml) and covers topics, modules, learning objectives, question bulk creation, and exam + PDF generation. All other `/api/*` endpoints require BasicAuth via `AUTH_USER` / `AUTH_PASSWORD`.
