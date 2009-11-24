ActionController::Routing::Routes.draw do |map|
  map.resources :sites
  map.resources :pages, :member => { :update_sections => :post }
end
