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

    def edit_message_link(message,string="")
      "<script>if (window.Comloque.user.can_edit_message(#{message.user.id})) { document.write(\"<a class=\\\"edit_message_link\\\" href=\\\"#{message.url}/edit\\\">#{string.gsub('"','\"')}</a>\") }</script>"
    end

    def delete_message_link(message,string="")
      "<script>if (window.Comloque.user.can_delete_message()) { document.write(\"<a class=\\\"delete_message_link\\\" href=\\\"#{message.url}/delete\\\">#{string.gsub('"','\"')}</a>\") }</script>"
    end

    def edit_topic_link(topic,string="")
      return "" unless topic.is_a?(Topic::Drop)
      "<script>if (window.Comloque.user.can_edit_topic(#{topic.user.id})) { document.write(\"<a class=\\\"edit_topic_link\\\" href=\\\"#{topic.url}/edit\\\">#{string.gsub('"','\"')}</a>\") }</script>"
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #
  protect_from_forgery with: :exception

  before_filter :get_theme
  before_filter :get_user
  before_filter :get_unread_private_topics, if:->(x){@user}
  def get_theme
    @theme = Theme.last # debug for now
  end

  def get_user
    if session[:user_id].is_a?(Integer)
      # we are including moderatorships here because it's used often in permission checking
      @user = User.includes(:moderatorships).find(session[:user_id])
    end
  end

  def get_unread_private_topics
    @unread_private_topics = PrivateTopicUser.where(user_id:@user.id).where("last_read < last_message").count
  end

  BODY_TRANSFORMS = [:add_authenticity_token].freeze

  alias_method :rails_render_to_body, :render_to_body

  def rails_render_to_string(*args, &block)
    options = _normalize_render(*args, &block)
    rails_render_to_body(options)
  end


  # Hard overwrite the rendering system to render the templates
  def render_to_body(options)
    # process the usual options (status, content_type, location)
    _process_options(options)
    # directly to the render text option
    return options[:text] if !options[:text].blank? && !options[:layout]
    return render_to_json(options[:json]) if !options[:json].blank?

    # set the body to the text if we are rendering that text to the layout
    if !options[:text].blank? && !options[:layout].blank?
      body = options[:text]
    elsif options[:rails]
      body = rails_render_to_body(options)
    else
      body = render_liquid_body(options)
    end

    layout = render_liquid_layout(body)
    BODY_TRANSFORMS.each{|method| __send__(method,layout)}
    layout
  end

  def render_to_json(json)
    json = json.to_json unless json.kind_of?(String)
    self.content_type ||= Mime::JSON
    json
  end

  # overwrite for actionview defaults
  def _layout_for_option2(name)
    case name
    when String     then name
    when Proc       then name
    when true       then true
    when :default   then true
    when false, nil then nil
    else
      raise ArgumentError,
        "String, Proc, :default, true, or false, expected for `layout'; you passed #{name.inspect}"
    end
  end

private
  def require_user!
    render text:"You must be logged in to view this page.", layout:true, status: :forbidden unless @user
  end

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
    @template_name = options[:template] if @template_name.nil?
    options[:prefixes].each do |prefix|
      template = @theme.templates.find_by_name("#{prefix.to_s}/#{@template_name}")
      if template
        @prefix = prefix
        return template
      end
    end
    nil
  end

  def no_template_found(options)
    self.status = 422
    "Unable to find a template for \"#{@template_name}\" in [#{options[:prefixes].join(',')}]"
  end

  COMLOQUE_PROTECTED_IVARS = %w(theme)

  def public_view_assigns
    view_assigns.reject{|k,v| COMLOQUE_PROTECTED_IVARS.include?(k)}
  end

  def csrf_meta_tags
    "<meta name=\"csrf-param\" content=\"#{request_forgery_protection_token.to_s}\">\n<meta name=\"csrf-token\" content=\"#{form_authenticity_token.to_s}\">"
  end

  def add_js_user
    out = "<script>window.Comloque = window.Comloque || {};
window.Comloque.user = window.Comloque.user || {};
window.Comloque.user.id = #{@user.try(:id) || "null"};
window.Comloque.user.is_admin = #{@user.try(:is_admin?) || false};
window.Comloque.user.is_mod = #{@user.try(:is_mod_of?,@forum.try(:id)) || false};
window.Comloque.user.can_edit_message = function(message_user_id) {
  if (window.Comloque.user == null)
    return false;
  if (window.Comloque.user.id == message_user_id)
    return true;
  if (window.Comloque.user.is_admin)
    return true;
  if (window.Comloque.user.is_mod)
    return true;
  return false;
}
window.Comloque.user.can_edit_topic = function(topic_user_id) {
  if (window.Comloque.user == null)
    return false;
  if (window.Comloque.user.id == topic_user_id)
    return true;
  if (window.Comloque.user.is_admin)
    return true;
  if (window.Comloque.user.is_mod)
    return true;
  return false;
}
window.Comloque.user.can_delete_message = function() {
  return true;
  if (window.Comloque.user == null)
    return false;
  if (window.Comloque.user.is_admin)
    return true;
  if (window.Comloque.user.is_mod)
    return true;
  return false;
}
</script>"
  end

  def layout_view_assigns(body)
    public_view_assigns.merge({'content_for_header'=>"#{csrf_meta_tags}\n#{add_js_user}",'content_for_layout'=>body})
  end

  def add_authenticity_token(body)
    body.gsub!("</form","<input type=\"hidden\" name=\"#{request_forgery_protection_token.to_s}\" value=\"#{form_authenticity_token}\"></form")
  end

  # def cleanup_view_runtime
  #   super - @message_sanitize_ms
  # end

  # def append_info_to_payload(payload)
  #   super
  #   payload[:message_sanitize_ms] = @message_sanitize_ms
  # end


  # module Instrumentation2
  #   extend ActiveSupport::Concern
  #   private
  #   module ClassMethods
  #     def log_process_action(payload) #:nodoc:
  #       messages, message_sanitize_ms = super, payload[:message_sanitize_ms]
  #       messages << ("message_sanitize_ms: %.1fms" % message_sanitize_ms.to_f) if message_sanitize_ms
  #       messages
  #     end
  #   end
  # end

  # ActionController::Base.include Instrumentation2

end
