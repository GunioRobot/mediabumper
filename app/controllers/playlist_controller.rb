class PlaylistController < ApplicationController
  before_filter :login_required, :except => :file
  
  def file
    @file = MediaFile.find(params[:id])
    # FIXME: set correct MIME type
    response.headers['Content-Type'] = 'audio/x-mpegurl'
    render :layout => false
  end
  
  def add
    respond_to do |wants|
      wants.js do
        f = MediaFile.find(params[:file_id])
        max = PlaylistsItem.maximum(:position, :conditions => ['playlist_id = ?', current_user.playlist.id])
        pos = max.nil? ? 1 : max + 1
        PlaylistsItem.create(:playlist_id => current_user.playlist.id,
                             :media_file_id => f.id,
                             :position => pos)
        
        render :update do |page|
          page.replace 'playlist-sidebar', :partial => 'playlist/sidebar'
          page.visual_effect :highlight, "media-file-#{f.id}"
        end
      end
    end
  end
  
  def play
    # FIXME: set correct MIME type
    response.headers['Content-Type'] = 'audio/x-mpegurl'
    render :layout => false
  end
end