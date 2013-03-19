Scotch::Application.routes.draw do

  resources :pages

  use_doorkeeper

  resources :report_templates

  # Users. Yay.
  devise_for :users, :path_names => {:sign_in => "login", :sign_out => "logout", :sign_up => "register"}, :controllers => {:sessions => "sessions"}

  # API

  namespace 'api', defaults: {format: :json} do
    match 'users/verify_credentials', to: 'users#verify_credentials'
  end
  
  get 'users/search' => 'users#search', :as => 'user_search'
  resources :users, :except => [:new, :destroy] do
    resources :watchers, :only => [:index] #show items a user is following
    resources :feedposts, :only => [:index]
  end
  resources :watchers, :only => [:new, :create, :destroy]

  resources :items
  resources :areas
  resources :allocations

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

  resources :messages

  resources :ticket_reservations

  # These don't really make sense outside of a group, so we make them
  # sub-resources for the index and new actions.
  resources :groups, :except => [:destroy], :shallow => true do
    resources :feedposts, :only => [:index]
    resources :positions, :only => [:index, :new] do
      post :bulk_create, :on => :collection
    end
    resources :events, :on => :member do
      get 'schedule', :on => :collection, :as => 'schedule'
    end
    resources :message_lists, :on => :member do
      resources :messages, :on => :member
    end
    resources :plans, :on => :member do
      resources :tasks, :on => :member do
        get :complete, :on => :member, :as => 'complete'
      end
      get 'gantt', :on => :member
    end
    resources :documents
    resources :folders, :except => [:index]
    resources :votings, :only => [:index, :new]
    resources :auditions, :on => :member do
      get 'signup', on: :member, as: 'signup'
    end
    resources :reports
    member do
      post :join
      post :leave
      post :archive
      get :tokens
    end
  end

  resources :events
  resources :positions, :only => [:destroy, :create]
  #resources :documents, :only => [:show, :edit, :update, :destroy, :create]
  resources :checkouts, :except => [:edit, :destroy, :new, :show]
  resources :votings, :only => [:show, :edit, :create, :update, :destroy]
  resources :notifications, :only => [:index] do
    get 'read', :on => :collection, :as => 'read'
  end

  resources :nominations, :only => [:create, :show, :edit, :update] do
    resources :feedposts, :only => [:index]
    member do
      match :vote
    end
  end
  
  resources :kudos do
    resources :kawards do
      resources :knominations do
        get 'vote', :on => :member, :as => 'vote'
      end
    end
  end

  # These things shouldn't ever really be accessed by someone other than the
  # webmaster.  They allow configuration of back-end type things.  Ideally,
  # more business logic will move to being set on pages like these in the
  # future.
  resources :roles
  resources :help_items, :only => [:show, :edit, :index, :update]

  resources :feedbacks, :only => [:create, :new]

  match 'feedposts/more' => 'feedposts#more', :as => :more_feedposts
  resources :feedposts, :except => [:index, :edit, :update, :new]

  get "dashboard/index"
  get "dashboard/calendar"
  get "dashboard/sysadmin"
  get "dashboard/terms"
  get "dashboard/search"

  root :to => "dashboard#root"
end
