class Admin::AssetsController < ApplicationController
  before_filter :get_theme

  def get_theme
    @theme = Theme.find(params[:theme_id])
  end

  def new
    @asset = Asset.new(theme:@theme)
  end

  def show
    @asset = @theme.assets.find(params[:id])
    respond_to do |format|
      format.json { render json: @asset.attributes.merge(source:@asset.source) }
    end
  end

  def create
    @asset = Asset.new(asset_params)
    @asset.theme = @theme if @theme
    @asset.set_key_to_attachment
    Asset.where(theme_id:@theme.id,key:@asset.key).destroy_all
    if @asset.save
      respond_to do |format|
        format.js   { render json:@asset.attributes.merge(public_url:@asset.public_url) }
        format.html { redirect_to [:admin, @theme] }
      end
    else
      respond_to do |format|
        format.js   { render json:@asset.errors, status: 422 }
        format.html { render action: :new }
      end
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
      respond_to do |format|
        format.json { render json:@asset.attributes.merge(public_url:@asset.public_url) }
        format.js   { render json:@asset.attributes.merge(public_url:@asset.public_url) }
        format.html { redirect_to [:admin, @theme] }
      end
    else
      respond_to do |format|
        format.js   { render json:@asset.errors, status: 422 }
        format.html { render action: :new }
      end
    end
  end

  def destroy
    @asset = @theme.assets.find(params[:id])
    @asset.destroy
    redirect_to [:admin, @theme]
  end

private

  def asset_params
    params[:asset].permit(:key,:source,:attachment)
  end
end
