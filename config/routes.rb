Rails.application.routes.draw do
  namespace :admin do
  get 'users/index'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  namespace :admin do
    resources :forums
    resources :categories

    resources :users do
      collection do
        get 'search'
      end
    end

    resources :themes do
      member do
        get 'export'
      end
      resources :templates
      resources :assets
    end

    resources :emojis
    resources :swear_words
  end

  root 'forum#index'
  get '/forum' => 'forum#index'
  get '/forum/:cat/:forum' => 'forum#topiclist'
  get '/forum/:cat/:forum/newtopic' => 'forum#newtopic'
  post '/forum/:cat/:forum/newtopic' => 'messages#create'
  get '/forum/:cat/:forum/:topic' => 'forum#topic'
  get '/forum/:cat/:forum/:topic/edit' => 'forum#edit_topic'
  post '/forum/:cat/:forum/:topic/edit' => 'forum#update_topic'
  post '/forum/:cat/:forum/:topic/reply' => 'messages#create'
  get '/forum/:cat/:forum/:topic/:message(.:format)' => 'messages#show'
  delete '/forum/:cat/:forum/:topic/:message' => 'messages#destroy'
  get '/forum/:cat/:forum/:topic/:message/edit' => 'messages#edit'
  post '/forum/:cat/:forum/:topic/:message/edit' => 'messages#update'
  get '/forum/:cat/:forum/:topic/:message/report' => 'reports#new'
  post '/forum/:cat/:forum/:topic/:message/report' => 'reports#create'
  get '/forum/:cat/:forum/:topic/:message/report/edit' => 'reports#edit'
  patch '/forum/:cat/:forum/:topic/:message/report' => 'reports#update'

  get '/inbox' => 'inbox#index'
  get '/inbox/new' => 'inbox#new'
  post '/inbox' => 'inbox#create'
  get '/inbox/:topic' => 'inbox#show'
  post '/inbox/:topic/reply' => 'inbox#create'

  get '/login' => 'login#index' if Rails.env.development? && INSTALLED_LOGINS.detect{|k,v| v}.blank?
  get '/auth/google_oauth2' => 'login#index' if Rails.env.development? && !INSTALLED_LOGINS['google']
  get '/auth/google_oauth2/callback' => 'login#login'
  get '/register' => 'login#register'
  post '/register' => 'login#do_register'
  get '/logout' => 'login#logout'
end
