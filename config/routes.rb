ActionController::Routing::Routes.draw do |map|
  map.resources :sites do |site|
    site.resources :pages, :member => { :update_sections => :post }
  end
end
