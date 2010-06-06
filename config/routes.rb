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

  # These don't really make sense outside of a group, so we make them
  # sub-resources.  This makes linking to specific examples more of a pain, but
  # it also adds a check to make sure things don't migrate somehow between
  # groups.
  resources :groups do
    resources :positions
    resources :events
    resources :documents
    resources :checkouts
    collection do
      get :shows
    end
  end

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
