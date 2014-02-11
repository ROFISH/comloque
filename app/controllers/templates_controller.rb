class TemplatesController < ApplicationController
  before_filter :get_theme

  def get_theme
    @theme = Theme.find(params[:theme_id])
  end

  def new
    @template = Template.new(theme:@theme)
  end

  def create
    @template = Template.new(template_params)
    @template.theme = @theme
    if @template.save
      redirect_to @theme
    else
      render action:'new'
    end
  end

  def edit
    @template = @theme.templates.find(params[:id])
    render action:'new'
  end

  def update
    @template = @theme.templates.find(params[:id])
    if @template.update_attributes(template_params)
      redirect_to @theme
    else
      render action:'new'
    end
  end

  def destroy
    @template = @theme.templates.find(params[:id])
    if @template.destroy
      flash[:notice] = "Delete successful"
    end

    redirect_to @theme
  end

private

  def template_params
    params[:template].permit(:name,:source)
  end
end
