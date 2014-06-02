class UpdateController < ApplicationController
  TURTLE_PATH = Rails.root + 'turtle'

  def manifest
    data = {
      :version  => current_code_version,
      :manifest => generate_code_manifest
    }
    render :json => data, :content_type => 'text/plain'
  end

  def file
    path = find_code_file(params[:path])

    if valid_code_file(path)
      send_file(path)
    else
      render :text => "File not found", :status => 404
    end
  end

  def check
    if params[:version] == current_code_version
      render :text => "OKAY"
    else
      render :text => "UPDATE PLZ"
    end
  end

  private

  def current_code_version
    # TODO on production, this will generate a file at deploy and read that
    Digest::SHA1.hexdigest(generate_code_manifest.sort.inspect)
  end

  def generate_code_manifest
    manifest = {}
    TURTLE_PATH.find do |file|
      next unless file.file? && file.to_s.end_with?('.lua')
      path = file.relative_path_from(TURTLE_PATH).to_s.sub(/\.lua$/, '')
      digest = Digest::SHA1.hexdigest(file.read)
      manifest[path] = {:size => file.size, :hash => digest}
    end
    manifest
  end

  def find_code_file(file)
    (TURTLE_PATH + (file + '.lua')).realpath
  end

  def valid_code_file(path)
    path.to_s.start_with?(TURTLE_PATH.to_s + "/") && path.file?
  end
end
