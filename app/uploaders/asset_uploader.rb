# encoding: utf-8

class AssetUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if ENV["AWS_ACCESS_KEY_ID"] && ENV["AWS_SECRET_ACCESS_KEY"]
    storage :fog
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
      thefilename = model.key.split(".css").first
      "#{thefilename}-#{model.digest}.css"
    else
      original_filename
    end
  end

  process :store_meta

  # Create different versions of your uploaded files:
  # Duplicate Shopify's image sizes.
  # version :pico do
  #   process :resize_to_fit => [16, 16]
  # end
  # version :icon do
  #   process :resize_to_fit => [32, 32]
  # end
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end
  # version :small do
  #   process :resize_to_fit => [100, 100]
  # end
  # version :compact do
  #   process :resize_to_fit => [160, 160]
  # end
  # version :medium do
  #   process :resize_to_fit => [240, 240]
  # end
  # version :large do
  #   process :resize_to_fit => [480, 480]
  # end
  # version :grande do
  #   process :resize_to_fit => [600, 600]
  # end

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
