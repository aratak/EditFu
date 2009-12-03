ActionController::Routing::Routes.draw do |map|
  map.devise_for :users

  map.resources :users
  map.resource :preferences

  map.resources :sites do |site|
    site.resources :pages, :member => { :update_sections => :post }
  end

  map.root :controller => 'sites'
end
