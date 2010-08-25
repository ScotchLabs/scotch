class Users::SessionsController < Devise::SessionsController
  prepend_before_filter :lookup_email
  
  def lookup_email
    unless params.nil? or params[:user].nil?
      if params[:user].has_key? :andrewid
        if params[:user][:andrewid].include? "@"
          params[:user][:email] = params[:user][:andrewid]
        else
          u = User.find_by_andrewid(params[:user][:andrewid])
          params[:user][:email] = u.nil? ? "#{params[:user][:andrewid]}@andrew.cmu.edu" : u.email
        end
      end
    end
  end
end
