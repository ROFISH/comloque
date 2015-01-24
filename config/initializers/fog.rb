if ENV["AWS_ACCESS_KEY_ID"] && ENV["AWS_SECRET_ACCESS_KEY"]
  print "Using AWS Access: #{ENV["AWS_ACCESS_KEY_ID"]}\n"
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',                        # required
      :aws_access_key_id      => ENV["AWS_ACCESS_KEY_ID"],     # required
      :aws_secret_access_key  => ENV["AWS_SECRET_ACCESS_KEY"], # required
      :path_style             => true                          # true: use the bucket-name.s3.aws.amazon.com, false: use s3.aws.amazon.com/bucketname. Mostly used with the domain doesn't work well (ie. dots in domain name break SSL, non-standard domains, etc.)
    }
    config.asset_host     = ENV['AWS_CDN']                    #optional
    config.fog_directory  = ENV['AWS_BUCKET']                       # required
    config.fog_public     = false                                   # optional, defaults to true
    #config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  end
end

CarrierWave::SanitizedFile.sanitize_regexp = /[^a-zA-Z0-9\.\-\+_\@]/

# swap the filename and version type
module CarrierWave
  module Uploader
    module Versions
      def full_filename(for_file)
        original_filename = super(for_file)
        return original_filename if version_name.blank?
        
        splitted = original_filename.split(".")
        splitted[-2] << "_#{version_name}"
        splitted.join(".")
      end
    end
  end
end
