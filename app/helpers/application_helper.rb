# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_to_stream(text, file_id)
    link_to text, :controller => 'playlist', :action => 'file', :id => file_id
  end
  
  def link_to_download(text, file_id)
    link_to text, :controller => 'file', :action => 'download', :id => file_id
  end
end