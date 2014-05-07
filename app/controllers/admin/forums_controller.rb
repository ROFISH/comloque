class Admin::ForumsController < ApplicationController
  def index
    @forums = Forum.all
  end

  def new
    @forum = Forum.new
  end

  def create
    @forum = Forum.new(forum_params)
    if @forum.save
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def show
    @forum = Forum.find(params[:id])
  end

  def edit
    @forum = Forum.find(params[:id])
    render action:'new'
  end

  def update
    @forum = Forum.find(params[:id])
    if @forum.update_attributes(forum_params)
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def destroy
    @forum = Forum.find(params[:id])
    if @forum.destroy
      flash[:notice] = "Delete successful"
    end

    redirect_to action:'index'
  end

private

  def forum_params
    params[:forum].permit(:name,:permalink)
  end
end
