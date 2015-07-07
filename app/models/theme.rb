class Theme < ActiveRecord::Base
  has_many :templates
  has_many :assets

  def import_zip
    nil
  end

  def import_zip=(zipfile)
    return if zipfile.blank? || zipfile.read.blank?
    raise if zipfile.content_type != 'application/zip'
    raise if zipfile.original_filename.last(3).downcase != 'zip'

    Zip::File.open(zipfile.to_io) do |zip_file|
      zip_file.each do |entry|

        if matched = entry.name.match(/comloque_theme\/assets\/(.+?)\z/)
          f = File.open("/tmp/#{matched[1]}","w")
          f.write entry.get_input_stream.read
          f.close
          f = File.open("/tmp/#{matched[1]}")

          asset = Asset.new
          asset.attachment = f
          asset.set_key_to_attachment
          self.assets << asset
        elsif matched = entry.name.match(/comloque_theme\/templates\/(.+?).liquid\z/)
          template_name = matched[1]
          self.templates << Template.new(name:template_name,source:entry.get_input_stream.read)
        else
          p "UNKNOWN IMPORT FILE: #{entry.name}"
        end

      end
    end
    
  end
end
