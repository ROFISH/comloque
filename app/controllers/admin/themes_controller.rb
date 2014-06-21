module Admin
class ThemesController < ApplicationController
  def index
    @themes = Theme.all
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = Theme.new(theme_params)
    if @theme.save
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def show
    @theme = Theme.find(params[:id])
  end

  def edit
    @theme = Theme.find(params[:id])
    render action:'new'
  end

  def update
    @theme = Theme.find(params[:id])
    if @theme.update_attributes(theme_params)
      redirect_to action:'index'
    else
      render action:'new'
    end
  end

  def destroy
    @theme = Theme.find(params[:id])
    if @theme.destroy
      flash[:notice] = "Delete successful"
    end

    redirect_to action:'index'
  end

private

  def theme_params
    params[:theme].permit(:name)
  end
end
end
