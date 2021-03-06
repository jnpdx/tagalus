ActionController::Routing::Routes.draw do |map|

  #API
  map.connect ':data_type/:data_name/:action.:format', :controller => 'api', :conditions => { :subdomain => 'api' }
  map.connect ':data_type/:data_name/:action', :controller => 'api', :format => 'json', :conditions => { :subdomain => 'api' }
  map.connect ':data_type/create.:format', :controller => 'api', :action => 'create', :conditions => { :subdomain => 'api' }
  
  map.connect '*other.:format', :controller => 'api', :action => "api_error", :conditions => { :subdomain => 'api' }
  map.connect '*other', :controller => 'api', :action => "api_error", :format => 'json', :conditions => { :subdomain => 'api' }

  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }


  map.resources :users

  map.resource :session

  map.resources :comments

  map.resources :definitions

  map.resources :tags
  
  map.resources :users
  
  map.resources :ajax_searchs
  
  map.resource  :session, :controller => 'sessions'
  
  
  map.root :controller => "tags"
  
  map.connect 'feed', :controller => 'tags', :action => 'index_feed', :format => :rss
  
  map.connect 'tag/:the_tag', :controller => 'tags', :action => 'show'
  map.connect 'tag/:the_tag/feed', :controller => 'tags', :action => 'show_feed', :format => :rss
  map.connect 'widget/:widget_title/:the_tag', :controller => 'widget', :action => 'show'
  
  map.connect '/add_tweet', :controller => 'tags', :action => 'add_tweet'
  
  map.connect '/vote/:def_id', :controller => 'definitions', :action => 'vote'
  
  map.connect 'search_suggest/', :controller => 'ajax_search', :action => 'show'
  map.connect '/search', :controller => 'ajax_search', :action => 'search'


  #map.signup  '/signup', :controller => 'users',   :action => 'new' 
  map.login  '/login',  :controller => 'sessions', :action => 'new_oauth_twitter'
  map.twitter_login '/twitter_login', :controller => 'sessions', :action => 'new_twitter'
  map.oauth_twitter_login '/oauth_twitter', :controller => 'sessions', :action => 'new_oauth_twitter'
  map.start_oauth '/start_oauth', :controller => 'users', :action => 'oauth_create'
  map.oauth_callback 'oauth_callback', :controller => 'sessions', :action => 'twitter_oauth_callback'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy' 
  map.user_details '/user-details', :controller => 'users', :action => 'update'
  
  #static pages
  map.connect 'about', :controller => 'static_display', :action => 'show', :to_display => 'about.html'
  map.connect 'beta', :controller => 'static_display', :action => 'show', :to_display => 'beta.html'
  map.connect 'terms-of-service', :controller => 'static_display', :action => 'show', :to_display => 'tos.html'

  #admin
  map.connect 'admin/:action', :controller => 'admin_controller'
  
  #sitemap
  map.connect 'sitemap.xml', :controller => 'site_map', :action => 'show'

  #trending
  map.connect 'trending', :controller => 'trending_on_twitter', :action => 'show'

  #backup
  map.connect 'backup_db', :controller => 'backup_controller', :action => 'download_backup'
  
  #favicon
  map.connect 'favicon.ico', :controller => 'static_display', :action => 'favicon_redirect'


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
