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

  def search
    #raise unless request.xhr?
    q = params[:q]
    q = q['term'] if q.is_a?(Hash)
    query = "%#{q.gsub("%","\\%")}%"
    thing = User.where("name ILIKE ?",query)
    count = thing.count
    page = params[:page].to_i
    page = 1 if page.blank? || page < 1
    results = thing.select([:id,:name]).order(:id).limit(10).offset(10*(page-1)).map{|x| [x.id,x.name]}

    render json:{count:count,results:results}
  end

private

  def user_params
    params[:user].permit(:name,:superuser)
  end
end
