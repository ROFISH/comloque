class Admin::AssetsController < ApplicationController
  before_filter :get_theme

  def get_theme
    @theme = Theme.find(params[:theme_id])
  end

  def new
    @asset = Asset.new(theme:@theme)
  end

  def create
    @asset = Asset.new(asset_params)
    @asset.theme = @theme if @theme
    if @asset.save
      redirect_to [:admin, @theme]
    else
      render action: :new
    end
  end

  def edit
    @asset = @theme.assets.find(params[:id])
    @page_title = "Editing #{@asset.key}"
    render action: :new
  end

  def update
    @asset = @theme.assets.find(params[:id])
    if @asset.update_attributes(asset_params)
      redirect_to [:admin, @theme]
    else
      render action: :new
    end
  end

  def destroy
    @asset = @theme.assets.find(params[:id])
    @asset.destroy
    redirect_to [:admin, @theme]
  end

private

  def asset_params
    params[:asset].permit(:key,:source)
  end
end
