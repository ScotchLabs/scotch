Scotch::Application.routes.draw do |map|
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # Keep in mind you can assign values other than :controller and :action

  # Users. Yay.
  devise_for :users
  resources :users

  # Items stand by themselves since we have an inventory that is global.  In
  # the future more things might be like this, but it would be better to have
  # such things exist as separate applications and simply consume the models
  # of Scotch via the REST API.
  resources :items

  # FIXME: DAMMIT RAILS TEAM
  # https://rails.lighthouseapp.com/projects/8994/tickets/3765-missing-shallow-routes-in-new-router-dsl
  # So rails 3 doesn't have support for shallow routes, which is exactly what
  # we need!  So, the stuff below is an ugly hack to do shallow routes by
  # hand.  At some point when the rails core team gets off their ass and
  # actually fixes this (they love rewriting things, not maintenance of APIs,
  # something about agile?) we'll go back and clean it up.  ARGH!

  # This line is to help out rails RESTful route lookup.  Without it rails
  # gets confused in some places when trying to create links to Show objects
  resources :shows, :controller => :groups
  resources :boards, :controller => :groups

  # These don't really make sense outside of a group, so we make them
  # sub-resources.  This makes linking to specific examples more of a pain, but
  # it also adds a check to make sure things don't migrate somehow between
  # groups.
  resources :groups, :shallow => true do
    resources :positions, :only => [:index, :new]
    resources :events, :only => [:index, :new]
    resources :documents, :only => [:index, :new]
    resources :checkouts, :only => [:index, :new]
    collection do
      get :shows
    end
  end
  resources :positions, :only => [:show, :edit, :update, :destroy, :create] 
  resources :events, :only => [:show, :edit, :update, :destroy, :create] 
  resources :documents, :only => [:show, :edit, :update, :destroy, :create] 
  resources :checkouts, :only => [:show, :edit, :update, :destroy, :create] 

  # These things shouldn't ever really be accessed by someone other than the
  # webmaster.  They allow configuration of back-end type things.  Ideally,
  # more business logic will move to being set on pages like these in the
  # future.
  namespace "admin" do
    resources :roles
    resources :item_categories
  end

  get "dashboard/index"
  root :to => "dashboard#index"
end
