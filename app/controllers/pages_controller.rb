class PagesController < ApplicationController
  layout 'pages'
  skip_before_filter :authenticate_user!, only: [:twilio, :index, :show, :recruit, :anniversary, :shows, :about, :subscribe]

  def index
    @show = Show.active.public.last
    @season = Show.mainstage.current_season if !@show
    
    if @show
      @reservation = TicketReservation.new
    end
  end

  def show
    @page = Page.find_by_address(params[:id])
  end

  def shows
    @seasons = Show.by_year.to_a.reverse
  end

  def subscribe
    c = Contact.create(protocol: 'email', address: params[:andrew] + "@andrew.cmu.edu")

    if c
      MessageMailer.subscribe_email(c).deliver
    end

    flash[:notice] = "You are now subscribed to our mailing list!"

    redirect_to root_path
  end

  def twilio
    # client = Twilio::REST::Client.new('ACce4ca7ae0ff2396ebc76a714d163bd42','3ed7d1684a38e3abac32b122d57f26b8')

    # client.account.sms.messages.create(from: '+1 412-567-1945', to: params['From'],
    #                                    body: 'Thank you! You are now on the SnS Mailing List')
    c = Contact.create(protocol: 'email', address: params['Body'] + "@andrew.cmu.edu")

    if c
      begin
        MessageMailer.subscribe_email(c).deliver
      rescue
      end
    end

    flash[:notice] = "You are now subscribed to our mailing list!"

    resp = Twilio::TwiML::Response.new do |r|
      r.Sms "You are now subscribed to our mailing list!", from: '+1 412-567-1945', to: params['From']
    end

    render xml: resp.text
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
