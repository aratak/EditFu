ActionController::Routing::Routes.draw do |map|
  # map.devise_for :users
  map.devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :registration => 'register', :sign_up => 'signup' }

  map.resource :editor_confirmation, :as => 'editors/confirmation'
  map.resource :owner_confirmation, :as => 'owners/confirmation'

  map.new_owner "/signup", :controller => :owners, :action => :new, :method => :get 
  map.resources :owners, :only => [:new, :create], :collection => { "terms_of_service" => :get, "privacy_policy" => :get }, :path_names => { :new => 'sign_up' }
  map.resource :owner, :only => [:destroy]

  map.resources :editors, :member => { :update_permissions => :post }

  map.resource :simple_preferences
  map.resource :owner_preferences, :member => { :downgrade => :post, :billing_update => :put }, :collection => { :identity => :post }

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
