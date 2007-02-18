class MediaFile < ActiveRecord::Base
  acts_as_ferret({ :fields => [:relative_path, :artist_name, :album_name, :song_name] },
                 { :analyzer => Ferret::Analysis::LetterAnalyzer.new })
  
  belongs_to :repository
  has_one :song
  
  EXTENSIONS = ['.mp3'].freeze
  
  class << self
    def index(path, repository)
      if self::EXTENSIONS.include? File.extname(path)
        relative_path = path.sub /^#{repository.path}#{File::SEPARATOR}/, ''
        mf = find_by_relative_path_and_repository_id(relative_path, repository.id)
        unless mf
          tags = Mediabumper::TaggedFile.new path
          
          # FIXME: improve the following block
          MediaFile.transaction do
            new_mf = MediaFile.create :relative_path => relative_path,
              :repository_id => repository.id, :size => File.size(path),
              :bitrate => 0, :duration => 0
            artist = Artist.find_or_create_by_name(tags.artist) if tags.artist
            album = Album.find_or_create_by_artist_id_and_name(artist.id, tags.album) if tags.album
            Song.create(:name => tags.title, :artist => artist, :album => album, :media_file => new_mf) if tags.title
          end
        end
      end
    end
    
    def recent(limit)
      find(:all, :order => 'created_at DESC', :limit => limit)
    end
  end
  
  def split_relative_path
    relative_path.split File::SEPARATOR
  end
  
  def path
    File.join(repository.path, relative_path)
  end
  
  def basename
    File.basename(relative_path)
  end
  
  # Returns the extension of the file without the leading dot (e.g. 'mp3')
  def extname
    File.extname(relative_path)[1..-1]
  end
  
  def artist
    song && song.artist
  end
  
  def album
    song && song.album
  end
  
  private  
    def artist_name
      song && song.artist.name
    end
    
    def album_name
      song && song.album.name
    end
    
    def song_name
      song && song.name
    end
end
