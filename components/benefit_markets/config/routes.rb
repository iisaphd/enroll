BenefitMarkets::Engine.routes.draw do
  namespace :products do
    resources :product_packages, :only => [:new, :create, :show]
  end
end
