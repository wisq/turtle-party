class UpdateController < ApplicationController
  TURTLE_PATH = Rails.root + 'turtle'

  def manifest
    manifest_text = generate_manifest.map do |key, (size, hash)|
      [key, size, hash].join(" ").to_s
    end.join("\n")

    render :text => manifest_text, :content_type => 'text/plain'
  end

  def file
    path = (TURTLE_PATH + (params[:path] + '.lua')).realpath

    if path.to_s.start_with?(TURTLE_PATH.to_s + "/") && path.file?
      send_file(path)
    else
      render :text => "File not found", :status => 404
    end
  end

  private

  def generate_manifest
    manifest = {}
    TURTLE_PATH.find do |file|
      next unless file.file? && file.to_s.end_with?('.lua')
      path = file.relative_path_from(TURTLE_PATH).to_s.sub(/\.lua$/, '')
      digest = Digest::SHA1.hexdigest(file.read)
      manifest[path] = [file.size, digest]
    end
    manifest
  end
end
