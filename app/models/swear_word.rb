class SwearWord < ActiveRecord::Base
  validates_presence_of :word, :mask
  validate :mask_cannot_be_bigger_than_word

  def mask_cannot_be_bigger_than_word
    unless word.blank? && mask.blank?
      if mask.length > word.length
        errors.add :mask, 'cannot be bigger than the word'
      end
    end
  end

  class SanitizeTransformer
    def initialize
      @all_swears = Hash[SwearWord.all.map{|x| [x.regexp,x]}]
    end

    def call(env)
      basenode = env[:node]
      return unless basenode.parent.nil? && basenode.is_a?(Nokogiri::HTML::DocumentFragment)

      stringlength = 0
      tagmap = []
      childparser = lambda do |parent|
        thislength = 0
        startlength = stringlength
        parent.children.each do |child|
          if child.is_a?(Nokogiri::XML::Text)
            childstart = thislength + startlength
            childend = childstart + child.text.length

            stringlength += child.text.length
            thislength += child.text.length

            tagmap << [(childstart..childend),child]
          else
            thislength += childparser.call(child)
          end
        end
        thislength
      end
      childparser.call(basenode)

      @all_swears.each do |regexp,swear|
        string = tagmap.map{|x| x.last.text}.join("")
        infloopfix = 0
        while match = string.match(regexp)
          break if infloopfix > 1000
          infloopfix += 1

          matchstart = match.begin(0)
          matchend = match.end(0)-1
          matchstart += match.captures[0].length if swear.require_beginning_space && match.captures[0].is_a?(String)
          matchend -= match.captures.last.length if swear.require_ending_space && match.captures.last.is_a?(String)

          # p matchstart
          # p matchend
          # print tagmap.map(&:inspect).join("\n")

          tagmap.each_with_index do |x,i|
            range = x.first
            node = x.last
            # if tag ends before the matched area
            if range.end < matchstart
              # do nothing, this tag occurs before the match

            # if tag starts after the match ed
            elsif range.begin > matchend
              # do nothing, this tag occurs after the match

            # if match is bigger and 100% contained in the tag
            elsif range.begin >= matchstart && range.end <= matchend
              # get the range of the mask to get
              replace_range = (range.begin-matchstart..range.end-matchstart-1)
              # get the whole length of this range
              replace_length = range.end - range.begin
              # get the replacement text from the range and extend it the length if necessary (this ensures the tags still match on next searches)
              replacement = swear.mask[replace_range]
              replacement += " " * (replacement.length - replace_length)
              x[1] = node.replace(replacement)

            # if it begins here and ends elsewhere
            elsif range.begin <= matchstart && range.end < matchend
              text = node.text
              matchstart_inside_text = matchstart - range.begin
              matchend_inside_text = text.length

              replace_length = matchend_inside_text - matchstart_inside_text
              replacement = swear.mask[0..replace_length-1]
              replacement += " " * (replacement.length - replace_length)

              newtext = text[0..matchstart_inside_text-1] + replacement
              x[1] = node.replace(newtext)
            #if it begins before and ends here
            elsif range.begin > matchstart && range.end >= matchend
              text = node.text
              matchstart_inside_text = 0
              matchend_inside_text = matchend - range.begin + 1

              replace_length = matchend_inside_text - matchstart_inside_text
              replace_range = (matchend-matchstart-replace_length+1)..(matchend-matchstart)
              replacement = swear.mask[replace_range]
              replacement += " " * (replacement.length - replace_length)

              newtext = replacement + text[matchend_inside_text..text.length]
              x[1] = node.replace(newtext)
            # the tag is bigger and 100% contained in the match
            elsif range.begin <= matchstart && range.end >= matchend
              text = node.text
              replace_length = matchend - matchstart + 1
              replacement = swear.mask[0..replace_length]
              replacement += " " * (replacement.length - replace_length)

              matchstart_inside_text = matchstart - range.begin
              matchend_inside_text = matchend - range.begin

              beginning_text = matchstart_inside_text > 0 ? text[0..matchstart_inside_text-1] : ""

              newtext = beginning_text + replacement + text[matchend_inside_text+1..text.length]
              x[1] = node.replace(newtext)
            end
          end

          # update the string for the next while loop
          string = tagmap.map{|x| x.last.text}.join("")
        end
      end

      #raise "stringlength: #{stringlength} string: #{string} tagmap: #{tagmap}"

      # thishtml = node.to_html
      # newhtml = thishtml.dup
      # @all_swears.each do |regexp, mask|
      #   newhtml.gsub!(regexp) do |loll|
      #     raise loll.inspect
      #   end
      # end
      # raise newhtml
    end
  end

  def regexp
    chars = []
    self.word.each_char do |char|
      if self.case_sensitive
        chars << case char.downcase
          when "a"
            "[AÀÁÂÄÆÃÅĀ4aàáâäæãåā\\@]"
          when "b"
            "[bß8B]"
          when "c"
            "[cçćčCÇĆČ]"
          when "e"
            "[EÈÉÊËĒĖĘÆŒ3eèéêëēėęæœ]"
          when "i"
            "[iîïíīįìIÎÏÍĪĮÌ1]"
          when "l"
            "[lłLŁ]"
          when "n"
            "[nñńNÑŃ]"
          when "o"
            "[oôöòóœøōõ0OÔÖÒÓŒØŌÕ]"
          when "s"
            "[sßśš5\\$SŚŠ]"
          when "u"
            "[uûüùúūUÛÜÙÚŪ]"
          when "y"
            "[yÿYŸ]"
          when "z"
            "[zžźżZŽŹŻ]"
          else
            char
        end
      else
        chars << case char
          when "A"
            "[AÀÁÂÄÆÃÅĀ4\\@]"
          when "a"
            "[aàáâäæãåā4\\@]"
          when "B"
            "[Bß8]"
          when "b"
            "[bß8]"
          when "c"
            "[cçćč]"
          when "C"
            "[CÇĆČ]"
          when "E"
            "[EÈÉÊËĒĖĘÆŒ3]"
          when "e"
            "[eèéêëēėęæœ3]"
          when "I"
            "[IÎÏÍĪĮÌ1]"
          when "i"
            "[iîïíīįì1]"
          when "l"
            "[lł]"
          when "L"
            "[LŁ]"
          when "n"
            "[nñń]"
          when "N"
            "[NÑŃ]"
          when "o"
            "[oôöòóœøōõ0]"
          when "O"
            "[OÔÖÒÓŒØŌÕ0]"
          when "s"
            "[sßśš5\\$]"
          when "S"
            "[SŚŠ5\\$]"
          when "u"
            "[uûüùúū]"
          when "U"
            "[UÛÜÙÚŪ]"
          when "y"
            "[yÿ]"
          when "Y"
            "[YŸ]"
          when "z"
            "[zžźż]"
          when "Z"
            "[ZŽŹŻ]"
          else
            char
        end
      end
    end
    regstr = ""
    regstr << "(\\A|\\s|\\.|\\-|\\*|\\;|\\&|\\,)" if self.require_beginning_space
    regstr << chars.join("[\\.\\s\\-\\*\\;\\&\\,]*?")
    regstr << "(\\s|\\z|\\.|\\-|\\*\\;|\\&|\\,)" if self.require_ending_space

    Regexp.new(regstr,(self.case_sensitive ? nil : 'i'))
  end
end
