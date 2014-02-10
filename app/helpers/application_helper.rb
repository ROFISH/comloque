module ApplicationHelper
end

module Comloque
  class AceField < ActionView::Helpers::Tags::Base
    def render
      options = @options.stringify_keys

      content_tag("pre",options.delete("value") { value_before_type_cast(object) }, id:"ace_field_#{@method_name}")
    end
  end
end

class ActionView::Helpers::FormBuilder
  def bs_field(thing,main_content)
    @template.content_tag(:div, class: "form-group") do
      (label thing, class:"col-sm-2 control-label") + @template.content_tag(:div, main_content, class: "col-sm-7 col-md-5")
    end
  end

  def bs_text_field(thing,options={})
    if options[:class].is_a?(Array)
      options[:class] << "form-control"
    else
      options[:class] = "#{options[:class]} form-control"
    end

    bs_field(thing, text_field(thing,options))
  end

  def bs_file_field(thing,options={})
    if options[:class].is_a?(Array)
      options[:class] << "form-control"
    else
      options[:class] = "#{options[:class]} form-control"
    end

    bs_field(thing, file_field(thing,options))
  end

  def bs_submit(btntext=nil)
    @template.content_tag(:div, class: "form-group") do
      @template.content_tag(:div, submit(btntext, class:"btn btn-primary"), class: "col-sm-offset-2 col-sm-7 col-md-5")
    end
  end

  def bs_ace_field(thing,options={})
    #ace_field = @template.content_tag(:pre,)
    #raise .to_yaml
    #raise method(:label).source_location.to_yaml

    Comloque::AceField.new(object_name,thing,@template,options).render
  end
end
