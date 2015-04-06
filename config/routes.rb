Rails.application.routes.draw do

  # FIXME: Do this properly later
  resource :plan_shopping do
    member do
      post 'checkout'
    end
  end

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  namespace :products do
    resources :plans, controller: :qhp do
      collection do
        get 'comparison'
        get 'summary'
      end
    end
  end

#Route pattern refactor BEGIN
  namespace :consumer do
    root 'people#index'

    resources :employee, :controller=>"people" do
    end
  end

  namespace :broker_agencies do
    root 'broker_profile#new'

    resources :broker_profile do
      get 'new'
      get 'my_account'
    end
  end

  namespace :employers do
    root 'employer_profiles#new'

    resources :employer_profiles do
      get 'new'
      get 'my_account'
      resources :family
    end
  end
#END

  resources :employee_roles do #TODO Delete
    get 'new'
    get 'my_account'
  end

  resources :people do #TODO Delete
    get 'select_employer'
    get 'my_account'
    get 'person_landing'

    collection do
      get 'plans_converson'
      post 'match_person'
      get 'get_employer'
      post 'person_confirm'
      post 'plan_details'
      post 'dependent_details'
      post 'add_dependents'
      get 'dependent_details'
      post 'save_dependents'
      delete 'remove_dependents'
      get 'select_plan'
      post 'select_plan'
    end

  end

  devise_for :users

  resources :families do
    get 'page/:page', :action => :index, :on => :collection

    resources :family_members, only: [:index, :new, :create]
    resources :households
  end

  resources :family_members, only: [:show, :edit, :update] do
     member do
       get :link_employee
       get :challenge_identity
     end
   end

  # Temporary for Generic Form Template
  match 'templates/form-template', to: 'welcome#form_template', via: [:get, :post]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".


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
end
