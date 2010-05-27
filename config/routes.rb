ActionController::Routing::Routes.draw do |map|
  map.devise_for :users

  map.resource :editor_confirmation, :as => 'editors/confirmation'
  map.resource :owner_confirmation, :as => 'owners/confirmation'

  map.resources :owners, :only => [:new, :create]
  map.resource :owner, :only => [:destroy]

  map.resources :editors, :member => { :update_permissions => :post }

  map.resource :simple_preferences
  map.resource :owner_preferences, :member => { :downgrade => :post }, :collection => { :identity => :post }

  map.resources :sites, :collection => { :ls => :get, :tree => :get } do |site|
    site.resources :pages, :collection => { :enable => :post }
    site.resources :images, :only => [:new, :create]
  end

  map.namespace :admin do |admin|
    admin.resources :owners
    admin.resources :audits
  end

  map.trial_period_expired "/trial-period-expired", :controller => 'shared', :action => 'trial_period'

  map.root :new_user_session
end
