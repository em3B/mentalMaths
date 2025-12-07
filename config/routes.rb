Rails.application.routes.draw do
  namespace :admin do
    get "dashboard", to: "dashboard#index"

    resources :capacity_requests, only: [ :index ] do
      member do
        patch :approve
        patch :decline
      end
    end
  end

  resource :profile, only: [ :show, :edit, :update ]
  get "payment_method/edit", to: "payments#edit", as: :edit_payment_method
  patch "payment_method", to: "payments#update"

  get "capacity_requests/new"
  get "capacity_requests/create"
  get "errors/not_found"
  get "errors/internal_server_error"
  get "errors/unprocessable_entity"
  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  if Rails.env.development?
    get "/test_404", to: "errors#not_found"
    get "/test_422", to: "errors#unprocessable_entity"
    get "/test_500", to: "errors#internal_server_error"
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "/favicon.ico", to: redirect("https://res.cloudinary.com/dm37aktki/image/upload/v1744891031/MentalMaths/Untitled_design_1_oh5xiz.png")

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

    get "students/:id/scores", to: "scores#show", as: :student_scores

    # Routes for capacity requests for limits (number of students, children, or classroom)
    resources :capacity_requests, only: [ :new, :create ]

    # Routes for topics
    resources :topics, only: [ :index, :show ] do
      collection do
        get "category/:category", to: "topics#index", as: :category
      end
      # Route to show questions for a specific topic (will handle the intro and question display)
      #   member do
      member do
        get "score"  # adds /topics/:id/score
        post "submit_score"
        get "intro"
        get "play"
      end
      resources :questions, only: [ :show ] do
        # You can add a route for answers here if you want to track answers directly
        post "answer", on: :member  # this will handle submitting answers to questions
      end
    end

resources :classrooms do
  member do
    post "assign_topic_to_class", to: "assigned_topics#create_for_class"
  end

  resources :students, only: [ :new, :create, :index, :destroy ] do
    member do
      post "assign_topic", to: "assigned_topics#create_for_user"
    end
    collection do
      get "show_password"
    end
  end
  delete "assigned_topics/:id", to: "assigned_topics#destroy_for_class", as: :assigned_topic
  get :scores, on: :member
end

post "/assign_topic_to_user/:user_id", to: "assigned_topics#create_for_user", as: :assign_topic_to_user
delete "/assigned_topics/:id/for_user/:user_id", to: "assigned_topics#destroy_for_user", as: :destroy_user_assigned_topic

    # dashboards
    get  "dashboard/teacher",           to: "dashboards#teacher",          as: :teacher_dashboard
    post "dashboard/teacher/create",    to: "dashboards#create_classroom", as: :create_classroom
    post "dashboard/teacher/add_student", to: "dashboards#create_student",  as: :create_student

    get  "dashboard/family",           to: "dashboards#family",         as: :family_dashboard
    post "dashboard/family/create",    to: "dashboards#create_child",   as: :create_child

    resources :scores, only: [ :index, :create ]

    # Score route (this could be shown after completing a session or at the end)
    get "score", to: "topics#score", as: "score"
end
