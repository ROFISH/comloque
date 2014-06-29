class Admin::CategoriesController < ApplicationController
  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def show
    @category = Category.find(params[:id])
  end

  def edit
    @category = Category.find(params[:id])
    render action:'new'
  end

  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(category_params)
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def destroy
    @category = Category.find(params[:id])
    if @category.destroy
      flash[:notice] = "Delete successful"
    end

    redirect_to action:'index'
  end

private

  def category_params
    params[:category].permit(:name,:permalink)
  end
end
