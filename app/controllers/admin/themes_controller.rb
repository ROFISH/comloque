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

  def export
    @theme = Theme.find(params[:id])
    zipfile_name = "/tmp/comloque_theme_#{@theme.id}.zip"
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      @theme.templates.all.each do |template|
        zipfile.get_output_stream("comloque_theme/templates/#{template.name}.liquid") {|os| os.write template.source}
      end
    end
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      @theme.assets.all.each do |asset|
        zipfile.get_output_stream("comloque_theme/assets/#{asset.key}") {|os| os.write asset.attachment.read}
      end
    end
    send_file zipfile_name
  end

private

  def theme_params
    params[:theme].permit(:name,:import_zip)
  end
end
end
