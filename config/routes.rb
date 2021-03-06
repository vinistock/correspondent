# frozen_string_literal: true

Correspondent::Engine.routes.draw do
  scope path: ":subscriber_type/:subscriber_id" do
    resources :notifications, only: %i[index destroy] do
      collection do
        get :preview
      end

      member do
        put :dismiss
      end
    end
  end
end
