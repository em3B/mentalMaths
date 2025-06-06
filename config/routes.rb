Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  controller :pages do
    get :about
    get :privacy
    get :disclosure
    get :disclaimer
  end

    # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
    # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
    # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

    # Defines the root path route ("/")
    # root "posts#index"

    # Root path (Landing page)
    root "home#index"

    devise_for :users

    # Custom topic routes (intro and play)
    get "topics/:id/intro", to: "topics#intro", as: "topic_intro"

    # Routes for topics
    resources :topics, only: [ :index, :show ] do
      # Route to show questions for a specific topic (will handle the intro and question display)
      #   member do
      member do
        get "score"  # adds /topics/:id/score
        get "intro"
        get "play"
      end
      resources :questions, only: [ :show ] do
        # You can add a route for answers here if you want to track answers directly
        post "answer", on: :member  # this will handle submitting answers to questions
      end
    end

    resources :scores, only: [ :index, :create ]

    # Score route (this could be shown after completing a session or at the end)
    get "score", to: "topics#score", as: "score"
end
