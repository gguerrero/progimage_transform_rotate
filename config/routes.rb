Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/transform/rotate/:id', to: 'transform#rotate'
    end
  end
end
