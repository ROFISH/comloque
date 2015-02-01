module Sanitizable
  ROOT_ELEMENTS = %w(p blockquote pre).freeze

  IsAllowedRootElements = lambda do |node|
    node.element? && ROOT_ELEMENTS.include?(node.name.downcase)
  end

  BrSplitText = lambda do |node|
    split_n = node.text.split("\n")
    if split_n.length > 1
      thisout = []
      split_n.each_with_index do |line|
        thisout << Nokogiri::XML::Text.new(line, node.document)
        thisout << Nokogiri::XML::Element.new('br',node.document)
      end
      thisout.pop # remove the last br
      thisout
    else
      [node]
    end
  end

  DeepCheckForNewLines = lambda do |node|
    out = []
    if node.is_a?(Nokogiri::XML::Text)
      out.concat BrSplitText.call(node)
    else
      replacements = node.children.map do |inner_node|
        inner_node.unlink
        DeepCheckForNewLines.call(inner_node)
      end
      replacements.flatten.each do |new_inner|
        node.add_child(new_inner)
      end
      out << node
    end
    out
  end

  UnstrandElements = lambda do |stranded_nodes,doc|
    new_ps = []
    new_p = Nokogiri::XML::Element.new "p", doc
    stranded_nodes.each do |node|
      if node.is_a?(Nokogiri::XML::Text) && node.text == "\n\n"
        # just do the new p if we are just two newsline
        new_ps << new_p
        new_p = Nokogiri::XML::Element.new "p", doc
      elsif node.is_a?(Nokogiri::XML::Text) && node.text =~ /\n\n+/
        splitted = node.text.split(/\n\n+/)
        # split doesn't do the empty node at the beginning
        # if node.text =~ /\A\n\n/
        #   new_ps << new_p
        #   new_p = Nokogiri::XML::Element.new "p", doc
        # end

        splitted.reject!{|x| x.blank?}

        splitted.each_with_index do |text,i|
          new_node = Nokogiri::XML::Text.new(text, node.document)
          DeepCheckForNewLines.call(new_node).each do |text_node|
            new_p.add_child(text_node)
          end

          # if the last thing
          if i+1 != splitted.length
            new_ps << new_p
            new_p = Nokogiri::XML::Element.new "p", doc
          end
        end

        # split doesn't do the empty node at the end
        if node.text =~ /\n\n\z/ && node != stranded_nodes.last
          new_ps << new_p
          new_p = Nokogiri::XML::Element.new "p", doc
        end
      else
        DeepCheckForNewLines.call(node).each do |text_node|
          new_p.add_child(text_node)
        end
      end
    end

    new_ps << new_p
    stranded_nodes.clear
    new_ps
  end

  OnlyAllowedRootElements = lambda do |env|
    node = env[:node]
    raise "When using OnlyAllowedRootElements, make sure that the root elements (#{ROOT_ELEMENTS.join(", ")}) are present in the whitelist." unless (env[:config][:elements] & ROOT_ELEMENTS).length == ROOT_ELEMENTS.length

    # this transformer ONLY works on the root node.
    return unless node.parent.nil? && node.is_a?(Nokogiri::HTML::DocumentFragment)

    doc = node # for ease of knowing what's going on

    next_node = doc.child
    stranded_nodes = []
    # for each root child of the doc
    while next_node
      this_node = next_node
      next_node = this_node.next_sibling

      # if it's an allowed root element, then keep it and add all bad elements before it
      if IsAllowedRootElements.call(this_node)
        unless stranded_nodes.empty?
          # if we have some bad nodes before this, then combine them into good element(s) before this one
          new_ps = UnstrandElements.call(stranded_nodes, doc)
          new_ps.each do |new_p|
            this_node.add_previous_sibling(new_p)
          end
        end
        next
      end

      # allow purely empty whitespace and we haven't stranded yet
      if stranded_nodes.length == 0 && this_node.is_a?(Nokogiri::XML::Text) && this_node.text =~ /\A\s*\z/
        next
      end
        
      # if it's not an allowed root element, remove it and add it to the list of bad elements
      this_node.unlink
      stranded_nodes << this_node
    end
    # if there are any stranded elements at the end, add them to the end in a good element
    unless stranded_nodes.empty?
      new_ps = UnstrandElements.call(stranded_nodes, doc)
      new_ps.each do |new_p|
        doc.add_child(new_p)
      end
    end
  end

  def basic_sanitize(string,transformers=[])
    Sanitize.fragment(string, Sanitize::Config.merge(Sanitize::Config::BASIC,
      transformers:[Sanitizable::OnlyAllowedRootElements] + transformers
    ))
  end

  # if false
  #   class SanitizeRuntimeRegistry
  #     extend ActiveSupport::PerThreadRegistry

  #     attr_accessor :runtime

  #     [:runtime].each do |val|
  #       class_eval %{ def self.#{val}; instance.#{val}; end }, __FILE__, __LINE__
  #       class_eval %{ def self.#{val}=(x); instance.#{val}=x; end }, __FILE__, __LINE__
  #     end
  #   end

  #   RUNTIME = SanitizeRuntimeRegistry.new
  #   RUNTIME.runtime = 0

  #   module SanitizeControllerRuntime
  #     extend ActiveSupport::Concern

  #     protected

  #     def process_action(action, *args)
  #       # We also need to reset the runtime before each action
  #       # because of queries in middleware or in cases we are streaming
  #       # and it won't be cleaned up by the method below.
  #       RUNTIME.runtime = 0
  #       super
  #     end

  #     def append_info_to_payload(payload)
  #       super
  #       payload[:sanitize_runtime] = RUNTIME.runtime
  #     end

  #     module ClassMethods
  #       def log_process_action(payload)
  #         messages, sanitize_runtime = super, payload[:sanitize_runtime]
  #         messages << ("Message Sanitize: %.1fms" % sanitize_runtime.to_f) if sanitize_runtime
  #         messages
  #       end
  #     end
  #   end

  #   ActiveSupport.on_load(:action_controller) do
  #     include SanitizeControllerRuntime
  #   end

  #   def basic_sanitize_with_runtime(string,transformers=[])
  #     out = ""
  #     RUNTIME.runtime += Benchmark.ms {
  #       out = basic_sanitize_without_runtime(string,transformers=[])
  #     }
  #     out
  #   end
  #   alias_method_chain :basic_sanitize, :runtime
  # end
end
