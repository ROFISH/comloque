class Admin::UsersController < ApplicationController
  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

private

  def user_params
    params[:user].permit(:name,:superuser)
  end
end
