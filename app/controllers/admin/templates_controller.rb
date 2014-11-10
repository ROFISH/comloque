module Admin
class TemplatesController < ApplicationController
  before_filter :get_theme

  # NOTE: In the Partner Store, this is actually in AppController, which doubles as a permission check
  # possibly move there in the future since it may be a good idea and copy/paste compatibility
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
      redirect_to [:admin,@theme]
    else
      render action:'new'
    end
  end

  def show
    @template = @theme.templates.find(params[:id])
    respond_to do |format|
      format.json { render json: @template }
    end
  end

  def edit
    @template = @theme.templates.find(params[:id])
    @page_title = "Editing #{@template.name}"
    render action:'new'
  end

  def update
    @template = @theme.templates.find(params[:id])
    if @template.update_attributes(template_params)
      respond_to do |format|
        format.json { render json:@template }
        format.js { head :ok }
        format.html {redirect_to [:admin,@theme]}
      end
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
    params[:template].permit(:name,:source,:is_layout,:altname,:is_snippet)
  end
end
end
