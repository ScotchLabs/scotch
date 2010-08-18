Scotch::Application.routes.draw do |map|

  resources :feed_posts

  resources :watchers

  # Users. Yay.
  devise_for :users, :path_names => {:sign_in => "login", :sign_out => "logout", :sign_up => "register"}
  resources :users

  # Items stand by themselves since we have an inventory that is global.  In
  # the future more things might be like this, but it would be better to have
  # such things exist as separate applications and simply consume the models
  # of Scotch via the REST API.
  resources :items do
    resources :checkouts, :only => [:index, :new]
  end

  # FIXME: DAMMIT RAILS TEAM
  # https://rails.lighthouseapp.com/projects/8994/tickets/3765-missing-shallow-routes-in-new-router-dsl
  # So rails 3 doesn't have support for shallow routes, which is exactly what
  # we need!  So, the stuff below is an ugly hack to do shallow routes by
  # hand.  At some point when the rails core team gets off their ass and
  # actually fixes this (they love rewriting things, not maintenance of APIs,
  # something about agile?) we'll go back and clean it up.  ARGH!

  # This line is to help out rails RESTful route lookup.  Without it rails
  # gets confused in some places when trying to create links to Show objects
  resources :shows, :controller => :groups, :group_type => "Show"
  resources :boards, :controller => :groups, :group_type => "Board"

  # These don't really make sense outside of a group, so we make them
  # sub-resources for the index and new actions.
  resources :groups, :shallow => true do
    resources :positions, :only => [:index, :new] do
      post :bulk_create, :on => :collection
    end
    resources :events, :only => [:index, :new]
    resources :documents, :only => [:index, :new]
    resources :checkouts, :only => [:index, :new]

    # FIXME: do we use this? should we?
    collection do
     get :shows
     get :boards
    end
    member do
      post :join
      post :leave
    end
  end
  resources :events, :only => [:show, :edit, :update, :destroy, :create] do
    put :signup, :on => :member
  end
  resources :positions, :only => [:show, :edit, :update, :destroy, :create]
  resources :documents, :only => [:show, :edit, :update, :destroy, :create]
  resources :checkouts, :only => [:show, :destroy, :create] do
    resources :checkout_events, :only => [:new]
  end
  resources :checkout_events, :except => [:new, :index, :show]

  # These things shouldn't ever really be accessed by someone other than the
  # webmaster.  They allow configuration of back-end type things.  Ideally,
  # more business logic will move to being set on pages like these in the
  # future.
  resources :roles
  resources :item_categories
  resources :help_items

  resources :feedbacks, :only => [:create, :new]

  get "dashboard/index"
  get "dashboard/calendar"
  get "dashboard/sysadmin"

  root :to => "dashboard#index"
end
