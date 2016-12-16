class UsersController < ApplicationController

  before_action :return_unless_loggedin , only: [:info, :logout]

  def login
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      render json: { hasura_id: user.id }
    else  
      render json: { message: "Unable to authenticate user"}, status: 401
    end
  end

  def logout
    session.delete(:user_id)
    @current_user = nil
  end

  def signup
    user = User.new(username: params[:username], password: params[:password])
    if user.save
      session[:user_id] = user.id
      render json: { message: "Success" }, status: 201
    else
      render json: user.errors.full_messages, status: 400
    end
  end

  def info
    hasura_id = current_user.id
    username = current_user.username
    render json: { hasura_id: hasura_id, username: username }
  end

private

  def logged_in?
    !!current_user
  end

  def return_unless_loggedin
    unless logged_in?
      render json: { message: "Not logged-in" }, status: 401
    end
  end

end
