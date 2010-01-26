ActionController::Routing::Routes.draw do |map|
  map.devise_for :users

  map.resource :editor_confirmation, :as => 'editors/confirmation'
  map.resource :owner_confirmation, :as => 'owners/confirmation'

  map.resources :owners, :only => [:new, :create]
  map.resource :owner, :only => [:destroy]
  map.resources :editors

  map.resource :preferences do |preferences|
    preferences.resource :plans, 
      :member => { :free => [:get, :post], :professional => [:get, :post] }
    preferences.resource :card, :only => [:edit, :update]
  end

  map.resources :sites, :collection => { :ls => :get } do |site|
    site.resources :pages
    site.resources :images, :only => [:new, :create]
  end

  map.namespace :admin do |admin|
    admin.resources :owners, :member => { :enable => :post, :disable => :post }
    admin.resources :audits
  end

  map.root :controller => 'home', :action => 'show'
end
