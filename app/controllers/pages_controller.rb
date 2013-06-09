class PagesController < ApplicationController
  layout 'pages'
  skip_before_filter :authenticate_user!, only: [:index, :show]

  def index
    @show = Show.active.public.first
    @season = Show.mainstage.current_season if !@show
    
    if @show
      @reservation = TicketReservation.new
    end
  end

  def show
    @page = Page.find_by_address(params[:id])
  end

  def shows
    @shows = Show.all.sort
  end

  def new
    @page = Page.new
    @page.page_sections.build
  end

  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, notice: 'Successfully created page!' }
      else
        format.html { render 'new' }
      end
    end
  end

  def edit
    @page = Page.find_by_address(params[:id])
  end
  
  def update
    @page = Page.find_by_address(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to @page, notice: 'Successfully edited page' }
      else
        format.html { render 'edit' }
      end
    end
  end

  def destroy
    @page = Page.find_by_address(params[:id])
    page.destroy
  end
end
