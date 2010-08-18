class Users::SessionsController < Devise::SessionsController
  prepend_before_filter :lookup_email
  
  def lookup_email
    unless params.nil? or params[:user].nil? or params[:user][:email].include? '@'
      u = User.find_by_andrew_id(params[:user][:email])
      if u.nil?
        params[:user][:email] << "@andrew.cmu.edu"
      else
        params[:user][:email] = u.email
      end
    end
  end
end
