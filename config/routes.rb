Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root 'exams#new'

  resources :exams, only: %i[index new create show] do
    member do
      get :marking_scheme
    end
    collection do
      get :preview_counts
    end
  end
  
  resources :exam_templates do
    member do
      post :generate
    end
  end

  resources :questions, only: %i[index new create edit update]
  resources :topics, only: %i[index show new create edit update]

  namespace :api do
    # OpenAPI spec — public (no BasicAuth). Serves `docs/openapi.yml` as
    # YAML by default, JSON on request. See Api::DocsController.
    get 'openapi(.:format)', to: 'docs#openapi',
                             defaults: { format: :yaml },
                             constraints: { format: /yaml|yml|json/ },
                             as: :openapi

    # Browsable docs UI (Scalar). Served as a static file from
    # public/api/docs.html; this route is a convenience redirect so
    # /api/docs works without the extension.
    get 'docs', to: redirect('/api/docs.html'), as: :docs

    resources :topics, only: %i[create show index update destroy] do
      resources :learning_objectives, only: %i[create update destroy]
      resources :topic_modules, only: %i[create]
    end

    resources :questions, only: [] do
      collection do
        post :bulk
      end
    end

    resources :exams, only: [:create] do
      member do
        get :pdf
        get :marking_scheme_pdf
      end
    end
  end

  if Rails.env.development?
    get '/question_types_preview', to: 'questions#types_preview'
  end
end
