class Asset < ActiveRecord::Base
  belongs_to :theme

  attr_reader :source_changed

  before_validation :set_key_to_attachment, :on => :create, if:->(x){x.key.blank? && !x.attachment.blank?}

  validates_presence_of :key#,:attachment
  validates :key, :uniqueness => { :scope => :theme_id }

  before_save :update_content_type, :if=>lambda{|x| x.key_changed? && self.content_type.blank?}
  before_save :update_md5, :if=>lambda{|x| x.source_changed}
  before_save :upload_source_as_file, :if=>lambda{|x| x.source_changed && x.css?}

  # Uploader must come after the above so the above is processed first.
  mount_uploader :attachment, AssetUploader

  def public_url(sym=nil)
    if sym.is_a?(Symbol)
      self.attachment.__send__(sym).url
    else
      self.attachment.url
    end
  end

  def set_key_to_attachment
    self.key = attachment.instance_exec{|x| original_filename}
    @source_changed = true if css?
  end

  def css?
    self.content_type == "text/css" || self.content_type == "application/javascript" || self.content_type == "text/javascript"
  end

  def source
    if css?
      @source ||= attachment.read
      @source.force_encoding("UTF-8")
      @source
    else
      nil
    end
  end

  def source=(input)
    @source = input
    @source_changed = true
  end

  def update_content_type
    if self.attachment.filename =~ /\.ttf\z/
      self.content_type = "application/octet-stream"
    else
      raise self.content_type.inspect
      self.content_type = "text/#{key.split(".").last}"
    end
  end

  def update_md5
    self.digest = Digest::MD5.hexdigest(@source)
  end

  module LiquidFilter
    def asset_url(input)
      return input if input[/^http/i]

      theme = @context.registers[:theme]
      return "" unless theme

      asset = theme.assets.find_by_key(input)
      return "" unless asset && asset.attachment

      asset.attachment.url
    end
  end

  def upload_source_as_file
    # Carrierwave, by default, will use the filename of a file uploaded.
    f = File.open("/tmp/#{key}","w")

    compiled_liquid = Liquid::Template.parse(@source)
    compiled_liquid.registers[:theme] = theme
    output = compiled_liquid.render!({}, :filters => [LiquidFilter])

    f.write output
    f.close

    f = File.open("/tmp/#{key}")

    self.attachment = f
  end


  # required for carrierwave meta

  def attachment_content_type=(value)
    self.content_type=value
  end

  def attachment_height=(value)
    self.height=value
  end

  def attachment_width=(value)
    self.width=value
  end

  def attachment_file_size=(value)
    self.size=value
  end

  def attachment_content_type
    self.content_type
  end

  def attachment_height
    self.height
  end

  def attachment_width
    self.width
  end

  def attachment_file_size
    self.size
  end

end
