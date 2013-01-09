require "base64"

class CaptureController < ApplicationController
  def image_capture
    image = params[:image]
    #imageContent = Base64.decode64(params[:image])
    save = params[:save]
    name = params[:name]
    type = params[:type]

    if !save.nil? and !name.nil? and (type == "JPG" or type == "PNG")
      #filename = Rails.root.join('app', 'assets/img/' +  name + "." + type)
      #File.open(filename, 'wb') do|f|
        #f.write(imageContent)
      #end
      img = Formulas.new
      img.name = name
      img.content = params[:image]
      img.save!
      render :text => "/capture/img/" + name
    end
  end

  def img
    img = Formulas.where('name = ?', params[:id]).first
    send_data Base64.decode64(img.content), :type => 'image/jpeg', :disposition => 'inline'
  end
end
