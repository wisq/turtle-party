class UpdateController < ApplicationController
  include TurtleCode

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
end
