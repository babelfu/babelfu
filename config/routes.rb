# frozen_string_literal: true

# == Route Map
#

Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "projects#index"

  resources :projects do
    resources :members, only: %i[index], controller: "project_members"
    resources :invitations, only: %i[index new create destroy], controller: "project_invitations"
    resource :accept_invitations, only: [:show], controller: "project_accept_invitations" do
      member do
        post :join
      end
    end

    member do
      post :sync
    end

    resources :branches, only: [:index, :show], constraints: { id: %r{[^/]+} } do
      member do
        post :sync
        post :commit_create
        get :commits
      end
    end

    resources :pull_requests, only: [:index, :show] do
      member do
        post :sync
        post :commit_create
        get :commits
      end
    end

    resources :proposals
  end
  resource :connections, only: :show do
    get "/github/callback", to: "connections#github_callback"
    delete :disconnect_github
    post :request_sync
  end

  authenticate :user, ->(user) { user.admin? } do
    mount GoodJob::Engine => "good_job"
  end
end
