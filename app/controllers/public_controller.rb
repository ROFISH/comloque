# PublicController is like ApplicationController, except for public facing pages.
# Use concerns for samey things (login, etc.)

class PublicController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #
  # Note that for a Liquid-based theme system, it's pretty far to actually do this aside from regexp the output
  # protect_from_forgery with: :exception

  before_filter :get_theme
  before_filter :get_user
  def get_theme
    @theme = Theme.first # debug for now
  end

  def get_user
    if session[:user_id].is_a?(Integer)
      @user = User.find(session[:user_id])
    end
  end

  # Hard overwrite the rendering system to render the templates
  def render_to_body(options)
    # render text:"blah", layout:false
    return options[:text] if !options[:text].blank? && !options[:layout]

    body = render_liquid_body(options)
    render_liquid_layout(body)
  end

private
  def render_liquid_body(options)
    template = get_template(options)
    return no_template_found(options) if template.blank?

    compiled_liquid = Liquid::Template.parse(template.source)
    body = if Rails.env.development?
      compiled_liquid.render!(public_view_assigns)
    else
      compiled_liquid.render(public_view_assigns)
    end
  end

  def render_liquid_layout(body)
    layout = @theme.templates.find_by_name("layouts/theme")
    return body if layout.blank?
    compiled_liquid = Liquid::Template.parse(layout.source)
    if Rails.env.development?
      compiled_liquid.render!(layout_view_assigns(body))
    else
      compiled_liquid.render(layout_view_assigns(body))
    end
  end

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

  def layout_view_assigns(body)
    public_view_assigns.merge({'content_for_header'=>"",'content_for_layout'=>body})
  end
end
