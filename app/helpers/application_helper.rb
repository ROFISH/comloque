module ApplicationHelper
end

module Comloque
  class AceField < ActionView::Helpers::Tags::Base
    def render
      options = @options.stringify_keys
      mode = options['mode'] || 'html'

      hidden_tag_options = options.dup
      add_default_name_and_id(hidden_tag_options)

      options['id'] = "ace_field_#{@method_name}"
      original_value = options.delete("value") { value_before_type_cast(object) }

      script = <<JAVASCRIPT
        var editor = ace.edit("#{options['id']}")
        editor.getSession().setMode("ace/mode/#{mode}");
        editor.setShowPrintMargin(false);
        editor.commands.addCommand({
            name: 'myCommand',
            bindKey: {win: 'Ctrl-S',  mac: 'Command-S'},
            exec: function(editor) {
              $("##{hidden_tag_options['id']}").parents('form').submit()
            },
            readOnly: true // false if this command should not apply in readOnly mode
        });
        editor.getSession().on('change', function(){
          $("##{hidden_tag_options['id']}").val(editor.getSession().getValue());
        });
        var loldefault = #{original_value.to_s.to_json}
        editor.getSession().setValue(loldefault)
        $("##{hidden_tag_options['id']}").val(loldefault)
JAVASCRIPT

      options.delete('mode')

      "\n".html_safe +
        hidden_field_tag(hidden_tag_options['name'],'', hidden_tag_options) +
        content_tag("pre",'', options) +
        content_tag("script",script.html_safe)
    end
  end
end

class ActionView::Helpers::FormBuilder
  def bs_field(thing,main_content)
    has_errors = !object.errors[thing].blank?

    error_text = if has_errors
      ret = ActiveSupport::SafeBuffer.new
      object.errors[thing].map do |error|
        ret << @template.content_tag(:span,"#{thing.to_s.titleize} #{error}",class: 'help-block')
      end
      ret
    else
      ""
    end

    divclass = "form-group"
    divclass += " has-error" if has_errors
    @template.content_tag(:div, class: divclass) do
      (label thing, class:"col-sm-2 control-label") + @template.content_tag(:div, main_content+error_text, class: "col-sm-7 col-md-5")
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
    @template.content_tag(:div, class: "form-group", id: "alert-saved", style:"display:none;") do
      @template.content_tag(:div, class: "col-sm-offset-2 col-sm-7 col-md-5") do
        @template.content_tag(:div, "#{object_name.titleize} Saved.", class: "alert alert-success")
      end
    end +
    @template.content_tag(:div, class: "form-group") do
      @template.content_tag(:div, submit(btntext, class:"btn btn-primary"), class: "col-sm-offset-2 col-sm-7 col-md-5")
    end
  end

  def bs_ace_field(thing,options={})
    ace_field_html = Comloque::AceField.new(object_name,thing,@template,options).render

    bs_field(thing, ace_field_html)
  end
end
