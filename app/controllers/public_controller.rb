# PublicController is like ApplicationController, except for public facing pages.
# Use concerns for samey things (login, etc.)

class PublicController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :get_theme
  def get_theme
    @theme = Theme.first # debug for now
  end

  # Hard overwrite the rendering system to render the templates
  def render_to_body(options)
    template = get_template(options)
    return no_template_found(options) if template.blank?

    compiled_liquid = Liquid::Template.parse(template.source)
    if Rails.env.development?
      compiled_liquid.render(public_view_assigns)
    else
      compiled_liquid.render!(public_view_assigns)
    end
  end

private
  def get_template(options)
    options[:prefixes].each do |prefix|
      template = @theme.templates.find_by_name("#{prefix.to_s}/#{options[:template]}")
      return template if template
    end
    nil
  end

  def no_template_found(options)
    "Unable to find a template for \"#{options[:template]}\" in [#{options[:prefixes].join(',')}]"
  end

  COMLOQUE_PROTECTED_IVARS = %w(theme)

  def public_view_assigns
    view_assigns.reject{|k,v| COMLOQUE_PROTECTED_IVARS.include?(k)}
  end
end
