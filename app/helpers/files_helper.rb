module FilesHelper
  # Returns an array of files present in repository and relative_path specified.
  # No relative path means the repository root. All files beginning with a dot
  # are suppressed from the returned array as they usually are hidden or system
  # files.
  def files_in(repository, relative_path)
    require 'natcmp'

    path = repository.path
    if relative_path && !relative_path.empty?
      path = File.join(path, relative_path)
    end

    Dir.entries(path).delete_if { |d| d =~ /^\./ }.sort { |a, b| String.natcmp(a, b, true) }
  end

  def parent_dir(path)
    path.split(File::SEPARATOR)[0..-2]
  end

  # Returns HTML code to display a directory entry which will depend on its
  # type.
  def directory_entry(repository, relative_path, file)
    path = relative_path ? File.join(repository.path, relative_path, file) : File.join(repository.path, file)

    if File.directory? path
      link_to h(file), :r => repository, :p => relative_path ? File.join(relative_path, file) : file
    elsif File.file?(path) && MediaFile::EXTENSIONS.include?(File.extname(path))
      real_relative_path = relative_path ? File.join(relative_path, file) : file
      returning '' do |html|
        html << content_tag(:div, :class => 'play-button-container') do
          link_to_stream(image_tag('icons/control_play_blue.png', :alt => "Play #{h file}", :title => "Play"), :r => repository, :p => real_relative_path)
        end
        html << h(file)
        html << content_tag(:div, '', :class => 'clear')
      end
    else
      h(file)
    end
  end
end
