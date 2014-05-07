# PublicController is like ApplicationController, except for public facing pages.
# Use concerns for samey things (login, etc.)

class PublicController < ActionController::Base

  before_filter :get_theme
  def get_theme
    @theme = Theme.first # debug for now
  end

  # Hard overwrite the rendering system to render the templates
  def render_to_body(options)
    template = get_template(options)
    return no_template_found(options) if template.blank?

    compiled_liquid = Liquid::Template.parse(template.source)
    compiled_liquid.render
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
end
