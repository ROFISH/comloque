FactoryGirl.define do
  factory :emoji do
    id 1
    name ":)"
    image Rack::Test::UploadedFile.new(File.join(Rails.root, 'test', 'files', 'smile.png')) 
    factory :emoji_sunglasses do
      id 2
      name "8)"
    end
  end

  factory :swear_word do
    word 'fuck'
    mask 'abcd'
    factory :swear_word_rofish do
      word 'Rofish'
      mask 'ROFISH'
      case_sensitive true
    end
  end
end
