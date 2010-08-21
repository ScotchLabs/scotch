class Users::SessionsController < Devise::SessionsController
  prepend_before_filter :lookup_email
  
  def lookup_email
    unless params.nil? or params[:user].nil?
      if params[:user].has_key? :andrew_id
        u = User.find_by_andrew_id(params[:user][:andrew_id])
        if u.nil?
          params[:user][:email] = "#{params[:user][:andrew_id]}@andrew.cmu.edu"
        else
          params[:user][:email] = u.email
        end
      end
    end
  end
end
