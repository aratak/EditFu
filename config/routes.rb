ActionController::Routing::Routes.draw do |map|
  map.devise_for :users

  map.resource :editor_confirmation, :as => 'editors/confirmation'
  map.resource :owner_confirmation, :as => 'owners/confirmation'

  map.resources :owners, :only => [:new, :create]
  map.resource :owner, :only => [:destroy]

  map.resources :editors do |editors|
    editors.resource :settings, :controller => 'editor_settings', 
      :only => [:show, :update]
  end

  map.resource :preferences, :member => { :downgrade => :post }

  map.resources :sites, :collection => { :ls => :get, :tree => :get } do |site|
    site.resources :pages, :collection => { :enable => :post }
    site.resources :images, :only => [:new, :create]
  end

  map.namespace :admin do |admin|
    admin.resources :owners, :member => { :enable => :post }
    admin.resources :audits
  end

  map.trial_period_expired "/trial-period-expired", :controller => 'shared', :action => 'trial_period'

  map.root :controller => 'home', :action => 'show'
end
