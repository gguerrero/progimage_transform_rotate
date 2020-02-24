Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/transform/rotate/:id', to: 'transform#rotate',
                                   as: :transform_rotate
    end
  end
end
