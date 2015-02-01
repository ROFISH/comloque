require 'test_helper'

class SanitizableTest < ActiveSupport::TestCase
  include Sanitizable

  def test_adds_p_tags
    assert_equal '<p>lol</p>', basic_sanitize('lol')
  end

  def test_links_add_nofollow
    assert_equal '<p><a href="http://google.com" rel="nofollow">teh googles</a></p>', basic_sanitize('<a href="http://google.com">teh googles</a>')
  end

  def test_newline_means_br
    assert_equal '<p>HAIKU BOT IS HERE<br>TO DO SOME TESTS WITH NEW LINES<br>DO NOT MANGLE THEM</p>', basic_sanitize("HAIKU BOT IS HERE\nTO DO SOME TESTS WITH NEW LINES\nDO NOT MANGLE THEM")
  end

  def test_deep_newline_means_br
    assert_equal '<p><b>HAIKU BOT IS HERE<br>TO DO SOME TESTS WITH NEW LINES<br>DO NOT MANGLE THEM</b></p>', basic_sanitize("<b>HAIKU BOT IS HERE\nTO DO SOME TESTS WITH NEW LINES\nDO NOT MANGLE THEM</b>")
  end

  def test_crazy_deep_newline_means_br
    assert_equal '<p><i><b>HAIKU BOT IS HERE<br>TO DO SOME TESTS</b> WITH NEW LINES<br>DO NOT MANGLE THEM</i></p>', basic_sanitize("<i><b>HAIKU BOT IS HERE\nTO DO SOME TESTS</b> WITH NEW LINES\nDO NOT MANGLE THEM</i>")
  end

  def test_double_newline_means_p_1
    assert_equal '<p>HAIKU BOT IS HERE</p><p>TO DO SOME TESTS WITH NEW LINES</p><p>DO NOT MANGLE THEM</p>', basic_sanitize("HAIKU BOT IS HERE\n\nTO DO SOME TESTS WITH NEW LINES\n\nDO NOT MANGLE THEM")
  end

  def test_multiple_newline_because_internet_1
    assert_equal '<p>HAIKU BOT IS HERE</p><p>TO DO SOME TESTS WITH NEW LINES</p><p>DO NOT MANGLE THEM</p>', basic_sanitize("HAIKU BOT IS HERE\n\n\n\n\n\n\n\n\nTO DO SOME TESTS WITH NEW LINES\n\n\n\n\n\n\n\n\nDO NOT MANGLE THEM")
  end

  def test_multiple_newline_because_internet_2
    assert_equal '<p>HAIKU BOT IS HERE</p><p>TO DO SOME TESTS WITH NEW LINES</p><p>DO NOT MANGLE THEM</p>', basic_sanitize("\n\n\n\n\n\n\n\n\nHAIKU BOT IS HERE\n\n\n\n\n\n\n\n\nTO DO SOME TESTS WITH NEW LINES\n\n\n\n\n\n\n\n\nDO NOT MANGLE THEM\n\n\n\n\n\n\n\n\n")
  end

  def test_both_br_and_p
    assert_equal '<p>My address is:</p><p>123 Test St.<br>Somewhere<br>The Internet</p><p>Please send asap!</p>', basic_sanitize("My address is:\n\n123 Test St.\nSomewhere\nThe Internet\n\nPlease send asap!")
  end

  def test_both_br_and_p_deep_1
    # note that this is correct HTML. The other option is to split into multiple like <p><b>My address</b></p><p><b>123</b></p>... but that's too consuming to consider, so forgetaboutit
    assert_equal '<p><b>My address is:<br><br>123 Test St.<br>Somewhere<br>The Internet<br><br>Please send asap!</b></p>', basic_sanitize("<b>My address is:\n\n123 Test St.\nSomewhere\nThe Internet\n\nPlease send asap!</b>")
  end

  def test_both_br_and_p_deep_2
    # since this one managed to keep their tags since each paragraph, it will have unique paragraph tags
    assert_equal '<p><b>My address is:</b></p><p><i>123 Test St.<br>Somewh</i>ere<br>The Internet</p><p><em>Please send asap!</em></p>', basic_sanitize("<b>My address is:</b>\n\n<i>123 Test St.\nSomewh</i>ere\nThe Internet\n\n<em>Please send asap!</em>")
  end

  def test_both_br_and_p_deep_3
    assert_equal '<p><b>My address</b> is:</p><p>123 Test <i>St.<br>Somewh</i>ere<br>The Internet</p><p>Please <em>send asap!</em></p>', basic_sanitize("<b>My address</b> is:\n\n123 Test <i>St.\nSomewh</i>ere\nThe Internet\n\nPlease <em>send asap!</em>")
  end

  def test_both_br_and_p_deep_4
    assert_equal '<p><b>My address is:</b></p><p><i>123 Test St.<br>Somewhere<br>The Internet</i></p><p><em>Please send asap!</em></p>', basic_sanitize("<b>My address is:</b>\n\n<i>123 Test St.\nSomewhere\nThe Internet</i>\n\n<em>Please send asap!</em>")
  end

  def test_weird_some_p_some_without
    assert_equal "<p>Proper <b>with some bold</b> too</p><p> Outside <i>too</i> heh </p><p> but then in<abbr>side</abbr> again <a href=\"lol\" rel=\"nofollow\">with a link!</a>!</p><p> and outside now!</p>", basic_sanitize("<p>Proper <b>with some bold</b> too</p> Outside <i>too</i> heh <p> but then in<abbr>side</abbr> again <a href='lol'>with a link!</a>!</p> and outside now!")
  end

  def test_proper_paragraphs
    # since this one managed to keep their tags in each paragraph, it will simply pass through
    assert_equal "<p>lol</p>\n\n<p>some tags these are</p>", basic_sanitize("<p>lol</p>\n\n<p>some tags these are</p>")
  end

  def test_emoji_1
    FactoryGirl.create(:emoji)
    assert_equal "<p>hey there <img src=\"/uploads/emoji/image/1/smile.png\"> i smile</p>", basic_sanitize("hey there :) i smile",[Emoji::SanitizeTransformer.new])
  end

  def test_emoji_2
    FactoryGirl.create(:emoji_sunglasses)
    assert_equal "<p>there are fourty eight (48) of them</p>", basic_sanitize("there are fourty eight (48) of them",[Emoji::SanitizeTransformer.new])
  end

  def test_emoji_3
    FactoryGirl.create(:emoji)
    assert_equal "<p>i like that <img src=\"/uploads/emoji/image/1/smile.png\"></p>", basic_sanitize("i like that :)",[Emoji::SanitizeTransformer.new])
  end

  def test_emoji_4
    FactoryGirl.create(:emoji)
    assert_equal "<p><img src=\"/uploads/emoji/image/1/smile.png\"> i like that</p>", basic_sanitize(":) i like that",[Emoji::SanitizeTransformer.new])
  end

  def test_emoji_5
    FactoryGirl.create(:emoji)
    assert_equal "<p><img src=\"/uploads/emoji/image/1/smile.png\"></p>", basic_sanitize(":)",[Emoji::SanitizeTransformer.new])
  end
end
