Rails.application.routes.draw do
  root 'exams#new'

  resources :exams, only: %i[index new create show] do
    member do
      get :marking_scheme
    end
    collection do
      get :preview_counts
    end
  end

  resources :questions, only: %i[index new create edit update]
  resources :topics, only: %i[index show new create edit update]

  namespace :api do
    resources :topics, only: [] do
      resources :learning_objectives, only: %i[create update destroy]
    end
  end

  if Rails.env.development?
    get '/question_types_preview', to: 'questions#types_preview'
  end
end
