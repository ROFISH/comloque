# PublicController is like ApplicationController, except for public facing pages.
# Use concerns for samey things (login, etc.)

class PublicController < ActionController::Base
  # Filters for the Liquid template
  module TextFilter
    def asset_url(input)
      return input if input[/^http/i]

      theme = @context.registers[:theme]
      return "" unless theme

      asset = theme.assets.find_by_key(input)
      return "" unless asset && asset.attachment

      asset.attachment.url
    end
    alias_method :shopify_asset_url, :asset_url

    def stylesheet_tag(input)
      #return "" if input[/^http/i] if ONLY_LOCAL
      %(<link href="#{input}" rel="stylesheet" type="text/css"  media="all" />)
    end

    def time_tag(time)
      return "<time />" unless time.is_a?(Time)

      currenttime = Time.now
      todaytime = Time.mktime(currenttime.year,currenttime.month,currenttime.day)
      stringoutput = if time > todaytime
        "Today, #{time.strftime("%H:%M")}"
      elsif time > (todaytime-86400)
        "Yesterday, #{time.strftime("%H:%M")}"
      else
        time.strftime("%B #{time.day.ordinalize}, %Y %H:%M")
      end
      "<time class=\"changeabletime\" datetime=\"#{time.iso8601}\">#{stringoutput}</time>"
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #
  protect_from_forgery with: :exception

  before_filter :get_theme
  before_filter :get_user
  def get_theme
    @theme = Theme.last # debug for now
  end

  def get_user
    if session[:user_id].is_a?(Integer)
      # we are including moderatorships here because it's used often in permission checking
      @user = User.includes(:moderatorships).find(session[:user_id])
    end
  end

  BODY_TRANSFORMS = [:add_authenticity_token].freeze

  # Hard overwrite the rendering system to render the templates
  def render_to_body(options)
    # render text:"blah", layout:false
    return options[:text] if !options[:text].blank? && !options[:layout]

    body = render_liquid_body(options)
    layout = render_liquid_layout(body)
    BODY_TRANSFORMS.each{|method| __send__(method,layout)}
    layout
  end

private
  def render_liquid_body(options)
    template = get_template(options)
    return no_template_found(options) if template.blank?

    compiled_liquid = Liquid::Template.parse(template.source)
    compiled_liquid.registers[:theme] = @theme
    compiled_liquid.registers[:user] = @user
    body = if Rails.env.development?
      compiled_liquid.render!(public_view_assigns, :filters => [TextFilter])
    else
      compiled_liquid.render(public_view_assigns, :filters => [TextFilter])
    end
  end

  def render_liquid_layout(body)
    layout = @theme.templates.find_by_name("layout/theme")
    return body if layout.blank?
    compiled_liquid = Liquid::Template.parse(layout.source)
    compiled_liquid.registers[:theme] = @theme
    compiled_liquid.registers[:user] = @user
    if Rails.env.development?
      compiled_liquid.render!(layout_view_assigns(body), :filters => [TextFilter])
    else
      compiled_liquid.render(layout_view_assigns(body), :filters => [TextFilter])
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
    self.status = 422
    "Unable to find a template for \"#{options[:template]}\" in [#{options[:prefixes].join(',')}]"
  end

  COMLOQUE_PROTECTED_IVARS = %w(theme)

  def public_view_assigns
    view_assigns.reject{|k,v| COMLOQUE_PROTECTED_IVARS.include?(k)}
  end

  def csrf_meta_tags
    "<meta name=\"csrf-param\" content=\"#{request_forgery_protection_token.to_s}\">\n<meta name=\"csrf-token\" content=\"#{form_authenticity_token.to_s}\">"
  end

  def layout_view_assigns(body)
    public_view_assigns.merge({'content_for_header'=>"#{csrf_meta_tags}",'content_for_layout'=>body})
  end

  def add_authenticity_token(body)
    body.gsub!("</form","<input type=\"hidden\" name=\"#{request_forgery_protection_token.to_s}\" value=\"#{form_authenticity_token}\"></form")
  end
end
