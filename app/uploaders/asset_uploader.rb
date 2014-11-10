# encoding: utf-8

class AssetUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if ENV["AWS_ACCESS_KEY_ID"] && ENV["AWS_SECRET_ACCESS_KEY"]
    storage :fog

    def self.fog_public
      true
    end

    def fog_public
      true
    end
  else
    storage :file
  end

  include CarrierWave::Meta

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if model.is_a?(Asset) && !model.theme_id.blank?
      "uploads/#{model.class.to_s.underscore}/#{model.theme_id}"
    else
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end

  def filename
    if model.css?
      splitted = model.key.split(".")
      ext = splitted.pop
      thefilename = splitted.join(".")
      "#{thefilename}-#{model.digest}.#{ext}"
    else
      original_filename
    end
  end

  process :store_meta

  def is_image?(picture)
    return false if model.content_type == 'image/svg+xml' #don't process svg files, they don't actually have a size
    return false if model.content_type == 'image/vnd.microsoft.icon' #don't process .ico files, they're not supported
    model.content_type =~ /\Aimage\//
  end

  def is_not_ttf?(picture)
    !(picture.original_filename =~ /\.ttf\z/)
  end

  process :store_meta, :if => :is_not_ttf?

  version :pico, :if => :is_image? do
    process :resize_to_limit => [16, 16]
  end
  version :icon, :if => :is_image? do
    process :resize_to_limit => [32, 32]
  end
  version :thumb, :if => :is_image? do
    process :resize_to_limit => [50, 50]
  end
  version :small, :if => :is_image? do
    process :resize_to_limit => [100, 100]
  end
  version :compact, :if => :is_image? do
    process :resize_to_limit => [160, 160]
  end
  version :medium, :if => :is_image? do
    process :resize_to_limit => [240, 240]
  end
  version :large, :if => :is_image? do
    process :resize_to_limit => [480, 480]
  end
  version :grande, :if => :is_image? do
    process :resize_to_limit => [600, 600]
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
