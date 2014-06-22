class Asset < ActiveRecord::Base
  belongs_to :theme

  attr_reader :source_changed

  before_save :update_content_type, :if=>lambda{|x| x.key_changed?}
  before_save :update_md5, :if=>lambda{|x| x.source_changed}
  before_save :upload_source_as_file, :if=>lambda{|x| x.source_changed && x.content_type == "text/css"}

  # Uploader must come after the above so the above is processed first.
  mount_uploader :attachment, AssetUploader

  def css?
    self.content_type == "text/css"
  end

  def source
    if css?
      @source ||= attachment.read
    else
      nil
    end
  end

  def source=(input)
    @source = input
    @source_changed = true
  end

  def update_content_type
    self.content_type = "text/#{key.split(".").last}"
  end

  def update_md5
    self.digest = Digest::MD5.hexdigest(@source)
  end

  def upload_source_as_file
    # Carrierwave, by default, will use the filename of a file uploaded.
    f = File.open("/tmp/#{key}","w")
    f.write @source
    f.close

    f = File.open("/tmp/#{key}")

    self.attachment = f
  end
end
