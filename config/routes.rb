Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root 'exams#new'

  resources :exams, only: %i[index new create show] do
    member do
      get :marking_scheme
      get :paper
      get :preview_frame
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

  resources :questions, only: %i[index new create edit update] do
    member do
      post :toggle_correct # MCQ paper-editor click
      post :toggle_blank   # Cloze paper-editor click
    end
  end
  resources :topics, only: %i[index show new create edit update]

  # Phase 6 — inspector rail content for a given exam_question. Drop-in
  # <turbo-frame id="rail-body">.
  resources :exam_questions, only: [] do
    member { get :rail }
  end

  # Redesign workspace (Phases 3-10). Single route; tab selected by ?tab=.
  get  '/workspace', to: 'workspaces#show'
  post '/workspace', to: 'workspaces#update'

  namespace :api do
    # OpenAPI spec — public (no BasicAuth). Serves `docs/openapi.yml` as
    # YAML by default, JSON on request. See Api::DocsController.
    get 'openapi(.:format)', to: 'docs#openapi',
                             defaults: { format: :yaml },
                             constraints: { format: /yaml|yml|json/ },
                             as: :openapi

    # Note: browsable docs UI (Scalar) is served as a static file from
    # public/api/docs.html. Rails' static-file middleware resolves
    # /api/docs -> /api/docs.html automatically via extension fallback,
    # so no route is needed here.

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
        patch :autosave
      end
    end
  end

  if Rails.env.development?
    get '/question_types_preview', to: 'questions#types_preview'
  end
end
