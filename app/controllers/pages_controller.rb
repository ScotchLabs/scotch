class PagesController < ApplicationController
  layout 'pages'
  skip_before_filter :authenticate_user!

  def index
    @show = Show.active.public.first
    @season = Show.current_season if !@show
  end

  def about
  end
end
