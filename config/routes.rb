Rails.application.routes.draw do
  root to: redirect("/scheduler")

  get  "/scheduler",     to: "polls#new",    as: :new_poll
  post "/scheduler",     to: "polls#create", as: :polls

  scope "/scheduler/:poll_token", as: :poll do
    get   "/",           to: "polls#show",   as: ""
    patch "/",           to: "polls#update"

    resources :time_slots, only: [:create, :destroy]

    resources :participants, only: [:create, :update] do
      resources :responses, only: [:create, :update]
    end

    post "responses/bulk", to: "responses#bulk", as: :bulk_responses
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
