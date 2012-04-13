Scotch::Application.routes.draw do |map|


  # Users. Yay.
  devise_for :users, :path_names => {:sign_in => "login", :sign_out => "logout", :sign_up => "register"}, :controllers => {:sessions => "sessions"}
  resources :users, :except => [:new, :destroy] do
    resources :watchers, :only => [:index] #show items a user is following
    resources :feedposts, :only => [:index]
  end
  resources :watchers, :only => [:new, :create, :destroy]

  # Items stand by themselves since we have an inventory that is global.  In
  # the future more things might be like this, but it would be better to have
  # such things exist as separate applications and simply consume the models
  # of Scotch via the REST API.
  resources :items, :except => [:index] do
    resources :checkouts, :only => [:index]
    resources :feedposts, :only => [:index]
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
  resources :shows, :except => [:destroy], :controller => :groups, :group_type => "Show" do
    resources :feedposts, :only => [:index]
  end
  resources :boards, :except => [:destroy], :controller => :groups, :group_type => "Board" do 
    resources :feedposts, :only => [:index]
    member do
      post :archive
    end
  end

  # These don't really make sense outside of a group, so we make them
  # sub-resources for the index and new actions.
  resources :groups, :except => [:destroy], :shallow => true do
    resources :feedposts, :only => [:index]
    resources :positions, :only => [:index, :new] do
      post :bulk_create, :on => :collection
    end
    resources :events, :only => [:index]
    resources :events, :only => [:show] do
      resources :event_attendees, :only => [:index]
    end
    resources :documents, :only => [:index, :new]
    resources :votings, :only => [:index, :new]
    member do
      post :join
      post :leave
      post :archive
    end
  end
  resources :events, :only => [:index] # for calendar to ajax a bunch of group's events at once
  resources :events, :only => [:show, :update, :destroy, :create] do
    resources :event_attendees, :only => [:create]
  end
  resources :event_attendees, :only => [:destroy]
  resources :positions, :only => [:destroy, :create]
  resources :documents, :only => [:index, :show, :edit, :update, :destroy, :create]
  resources :checkouts, :except => [:edit, :destroy, :new, :show]
  resources :votings, :only => [:show, :edit, :create, :update, :destroy]

  resources :nominations, :only => [:create, :show, :edit, :update] do
    member do
      post :vote
    end
  end

  # These things shouldn't ever really be accessed by someone other than the
  # webmaster.  They allow configuration of back-end type things.  Ideally,
  # more business logic will move to being set on pages like these in the
  # future.
  resources :roles
  resources :item_categories, :except => [:destroy]
  resources :help_items, :only => [:show, :edit, :index, :update]

  resources :feedbacks, :only => [:create, :new]

  resources :feedposts, :except => [:index, :edit, :update, :new]

  get "dashboard/index"
  get "dashboard/calendar"
  get "dashboard/sysadmin"
  get "dashboard/terms"
  get "dashboard/search"

  root :to => "dashboard#root"
end
