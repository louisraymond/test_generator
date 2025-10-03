Rails.application.routes.draw do
  root 'exams#new'

  resources :exams, only: %i[new create show] do
    member do
      get :marking_scheme
    end
  end

  if Rails.env.development?
    get '/question_types_preview', to: 'questions#types_preview'
  end
end
