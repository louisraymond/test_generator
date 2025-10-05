Rails.application.routes.draw do
  root 'exams#new'

  resources :exams, only: %i[new create show] do
    member do
      get :marking_scheme
    end
    collection do
      get :preview_counts
    end
  end

  resources :questions, only: [:index]
  resources :topics, only: %i[index show new create edit update]

  if Rails.env.development?
    get '/question_types_preview', to: 'questions#types_preview'
  end
end
