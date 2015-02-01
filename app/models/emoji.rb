class Emoji < ActiveRecord::Base
  mount_uploader :image, FileUploader


  class SanitizeTransformer
    def initialize
      # OPTIMIZATION TODO: Try and keep this information in memory for longer. As of right now it reloads on each rendered message, and that's bad.
      @all_emoji = Emoji.all.to_a
    end

    def call(env)
      node = env[:node]
      return unless node.is_a?(Nokogiri::XML::Text)

      # use dups to check for changes
      newstring = node.content.dup
      @all_emoji.each do |emoji|
        newstring = newstring.gsub(regexp(emoji), %(\\1<img src="#{emoji.image.url}" />\\2))
      end

      # if we have any changes, replace them and whitelist the img tags
      if newstring != node.content
        replacements = node.replace(newstring)
        {:node_whitelist => replacements.select{|x| x.is_a?(Nokogiri::XML::Element) && x.name == 'img'}}
      end
    end

    def regexp(emoji)
      Regexp.new("(\\A|\\s)"+emoji.name.gsub(/([^a-zA-Z0-9])/,'\\\\\1')+"(\\s|\\z)")
    end
  end
end
