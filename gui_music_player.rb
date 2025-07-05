####################################
#               Main               #
#             Program              #
####################################


## albums.txt file structure ##

# <number of albums>
# <first album's title>
# <first album's artist>
# <first album's genre>
# <first album's artwork location>
# <number of tracks in album>
# <first track's title>
# <first track's location>
# <first track's artwork location>   (new visual feature)
# ... and so on
## end of albums.txt file structure

require './modules'
require './album'
require './track'
require './artwork'
require './ui'

class MusicPlayerMain < Gosu::Window

  def initialize
    super(WIDTH, HEIGHT, fullscreen: false)
    self.caption = "Music Player"

    @title = Gosu::Font.new(50, bold: true, name: "Courier New")
    @ui_font = Gosu::Font.new(30, bold: true, name: "Verdana")
    @detail_font_title = Gosu::Font.new(35, bold: true, name: "Times New Roman")
    @detail_font = Gosu::Font.new(30, bold: true, name: "Times New Roman")
    @genre_font = Gosu::Font.new(28, bold: true, italic: true, name: "Calibri")
    @font = Gosu::Font.new(20)
    @search_field = TextField.new(self, @font, WIDTH - 320, 500, 200, @font.height)

    @search_button = SearchButton.new(WIDTH - 105, 500, 60)
    @pop_button = PopButton.new(WIDTH - 320, 550, 30)
    @classic_button = ClassicButton.new(WIDTH - 275, 550, 58)
    @jazz_button = JazzButton.new(WIDTH - 202, 550, 35)
    @rock_button = RockButton.new(WIDTH - 152, 550, 40)
    @various_button = VariousButton.new(WIDTH - 97, 550, 60)

    @create_button = CreatePlaylistButton.new(WIDTH - 505, 40, 145)
    @edit_button = EditButton.new(WIDTH - 580, 40, 36)
    @delete_button = DeleteButton.new(WIDTH - 650, 40, 55)
    @okay_button = OkayButton.new((675/2) - 100, 560, 85)
    @confirm_button = ConfirmButton.new((675/2) - 100, 560, 60)
    @cancel_button = CancelButton.new((675/2) + 80, 560, 90)
    @add_button = AddButton.new(675 - 100, 560, 55)
    @added_tracks = Array.new       # For tracks in creating playlist
    @all_tracks = Array.new
    @searched_tracks = Array.new

    @back_button_playlist = BackButton.new((674/2) - 50, 610, 23, 26)
    @next_button_playlist = NextButton.new((674/2) + 47, 610, 23, 26)

    @back_button_album = BackButton.new((674/2) - 50, 610, 23, 26)
    @next_button_album = NextButton.new((674/2) + 47, 610, 23, 26)

    @back_button_track = BackButton.new(WIDTH-175-50, 610, 23, 26)
    @next_button_track = NextButton.new(WIDTH-175+47, 610, 23, 26)

		# New Playback controls
    @back_button_music = PreviousSong.new((WIDTH/2) - 80, 685, 30, 35)
    @next_button_music = NextSong.new((WIDTH/2) + 40, 685, 30, 35)
    @play_button = PlayButton.new((WIDTH/2) - 30, 680)

		# New Volume controls
    @vol_down_button = VolDownButton.new(WIDTH-215, 700)
    @vol_up_button = VolUpButton.new(WIDTH-70, 688)
    @volume_display = Volume.new(WIDTH-175, 680)

    @volume = 1.0

    @create_mode = false
    @edit_mode = false
    @search_track = nil
    @searched_album = nil
    @playing_album = nil
    @playing_song_index = nil
    @playlist = nil
    @playlist_count = 0

    @genre = nil
    @selecting_album = nil

    @albums = read_albums()

    @album_page = 1
    @track_page = 1
    @playlist_page = 1
  end

  # Check if mouse is in the area
  def is_mouse_in(leftX, topY, rightX, bottomY)
    mouse_x.between?(leftX, rightX) && mouse_y.between?(topY, bottomY)
  end

  # Play the track, reset playing_album if out of bound
  def play_track(track_index, album)
    if track_index < 0 or track_index == album.tracks.length
      @song.stop
      @playing_album = nil
      @playing_song_index = nil
    else
      @song = Gosu::Song.new(album.tracks[track_index].location)
      @song.volume = @volume
      @song.play(false)
    end
  end

  def lower_case(text)
    text.downcase
  end

  # Search track function
  def search(track)
    track = lower_case(track)
    @searched_album = nil
    if @searched_tracks.count > 0
      @searched_tracks = Array.new
    end
    @selecting_album = nil
    @new_album = nil
    @genre = nil
    i = 0
    while (i < @albums.count)
      j = 0
      while (j < @albums[i].tracks.count)
        if (lower_case(@albums[i].tracks[j].title).include?(track))
          @searched_tracks << @albums[i].tracks[j]
        end
        j += 1
      end
      i += 1
    end
    results = @searched_tracks
    @searched_album = Album.new("Searched Track", "Various", GENRE_NAMES[Genre::VARIOUS], ArtWork.new("images/new.jpg"), results.map(&:dup))
    @selecting_album = @searched_album
  end

  # searched track draw
  def draw_searched_track()
    if !@selecting_album
      if @searched_album
        x = 699
        y = 96
        index = (@track_page - 1) * 10
        count = 0
        while index < @searched_tracks.count && count < 10
          track = @searched_tracks[index]
          @search_track = track
          track.x = x
          track.y = y
          track.draw

          case track.state
          when State::CLICKED, State::CLICKED + State::SELECTED
            track.draw_clicked
          when State::HOVERED, State::HOVERED + State::SELECTED
            track.draw_hovered
          when State::SELECTED
            track.draw_selected
          end
          index += 1
          count += 1
          y += 39
        end
      end
    end
  end

  # Draw tracks by Genre
  def draw_tracks_by_genre(genre)
    if genre != nil
      @selecting_album = nil
      @genre_font.draw_text(GENRE_NAMES[genre], WIDTH - 325, 60, ZOrder::UI, 1, 1, Gosu::Color::BLUE)
      i = 0
      new_track = Array.new
      while i < @albums.count
        if GENRE_NAMES[genre] == @albums[i].genre
          index = 0
          while index < @albums[i].tracks.count
            new_track << @albums[i].tracks[index]
            index += 1
          end
        end
        i += 1
      end
      @tracks_by_genre = new_track.count
      if @tracks_by_genre != 0
        @title.draw_text(" (" + new_track.count.to_s + ")", WIDTH - 180, 20, ZOrder::UI, 1, 1, TEXT_COLOR)
        new_album = Album.new(GENRE_NAMES[genre] + " Album", 'Various', genre, ArtWork.new("images/new.jpg"), new_track)
        x = 699
        y = 96
        index = (@track_page - 1) * 10
        count = 0
        while index < new_album.tracks.count && count < 10
          @selecting_album = new_album
          @new_album = new_album
          track = new_album.tracks[index]
          track.x = x
          track.y = y
          track.draw
          
          case track.state
          when State::CLICKED, State::CLICKED + State::SELECTED
            track.draw_clicked
          when State::HOVERED, State::HOVERED + State::SELECTED
            track.draw_hovered
          when State::SELECTED
            track.draw_selected
          end
          index += 1
          count += 1
          y += 39
        end
      end
    end
  end

  # Show all tracks to add to a new playlist
  def create_new_playlist
    sleep(0.1)
    @create_mode = true
    if Gosu::Song.current_song != nil
      @song.stop
      @playing_song_index = nil
      @playing_album = nil
    end
    @track_page = 1
    @new_album = nil
    @playlist = nil
    @added_tracks.clear
    @genre = nil
  end

  def draw_all_tracks
    if @create_mode
      if @edit_mode
        @title.draw_text("Editing Playlist", 35, 60, ZOrder::UI, 1, 1, TEXT_COLOR)
      else
        @title.draw_text("Creating Playlist", 35, 60, ZOrder::UI, 1, 1, TEXT_COLOR)
      end
      if @all_tracks.count == 0
        album_index = 0
        while album_index < @albums.count
          track_index = 0
          while track_index < @albums[album_index].tracks.count
            @all_tracks << @albums[album_index].tracks[track_index].dup
            track_index += 1
          end
          album_index += 1
        end
      end
      @title.draw_text(" (" + @all_tracks.count.to_s + ")", WIDTH - 180, 20, ZOrder::UI, 1, 1, TEXT_COLOR)
      new_album = Album.new(GENRE_NAMES[Genre::VARIOUS] + " Album", 'Various', Genre::VARIOUS, ArtWork.new("images/new.jpg"), @all_tracks)
      x = 699
      y = 96
      index = (@track_page - 1) * 10
      count = 0
      while index < new_album.tracks.count && count < 10
        @selecting_album = new_album
        track = new_album.tracks[index]
        track.x = x
        track.y = y
        track.draw
        
        case track.state
        when State::CLICKED, State::CLICKED + State::SELECTED
          track.draw_clicked
        when State::HOVERED, State::HOVERED + State::SELECTED
          track.draw_hovered
        when State::SELECTED
          track.draw_selected
        end
        index += 1
        count += 1
        y += 39
      end
      if @playlist && !@playlist.tracks.empty?
        
        x_cor = 50
        y_cor = 110
        index = (@playlist_page - 1) * 10
        count = 0
        while index < @playlist.tracks.count && count < 10
          track = @playlist.tracks[index]
          track.x = x_cor
          track.y = y_cor
          track.draw

          if is_mouse_in(track.x - PADDING, track.y - 6, track.x + 325, track.y + 30)
            if button_down?(Gosu::MsLeft)
              track.state = State::CLICKED + State::SELECTED
              sleep(0.5)
              @added_tracks.delete(track)
            else
              track.state = State::HOVERED + (track.state >= State::SELECTED ? State::SELECTED : 0)
            end
          else
            track.state = State::NONE
          end

          index += 1
          count += 1
          y_cor += 39
        end
      end
    end
  end

  def add_track
    if @playing_song_index != nil
      @added_tracks << @selecting_album.tracks[@playing_song_index].dup
      @playlist = Album.new(GENRE_NAMES[Genre::VARIOUS] + " Album", "Various", GENRE_NAMES[Genre::VARIOUS], ArtWork.new("images/new.jpg"), @added_tracks)
    end
  end

  def create_album
    @playlist_count += 1
    copied_tracks = @added_tracks.map(&:dup)  # clone each track object
    playlist = Album.new("Playlist " + @playlist_count.to_s, "Various", GENRE_NAMES[Genre::VARIOUS], ArtWork.new("images/new.jpg"), copied_tracks)
    @albums << playlist
  end

  # Edit mode
  def edit
    @edit_mode = true
    @create_mode = true
    @playlist_page = 1
    @editing_album = @selecting_album
    @added_tracks = @editing_album.tracks.map(&:dup)
    @playlist = Album.new(@selecting_album.title, @selecting_album.artist, @selecting_album.genre, @selecting_album.artwork, @added_tracks)
  end

  # Drawing functions

  def draw_background
    @title.draw_text("Albums", 35, 20, ZOrder::UI, 1, 1, TEXT_COLOR)
    @title.draw_text("Tracks", WIDTH - 325, 20, ZOrder::UI, 1, 1, TEXT_COLOR)
    draw_quad(0, 0, TOP_BG_COLOR, WIDTH, 0, TOP_BG_COLOR, 0, HEIGHT, BOTTOM_BG_COLOR, WIDTH, HEIGHT, BOTTOM_BG_COLOR, ZOrder::BACKGROUND) # Draw the Main Background
    draw_rect(WIDTH - 350, 0, WIDTH, HEIGHT, 0x0a_000000, ZOrder::MID) # Draw the background for tracks
    draw_rect(0, HEIGHT - 125, WIDTH, 125, CONTROL_BAR_COLOR, ZOrder::MID) # Draw the control bar
  end

  def draw_albums
    if !@create_mode
      x = 30
      y = 80

      index = (@album_page - 1) * 4
      count = 0

      while index < @albums.size && count < 4
        album = @albums[index]
        album.x = x
        album.y = y
        album.draw

        case album.state
        when State::CLICKED
          album.draw_clicked
        when State::HOVERED
          album.draw_hovered
        when State::SELECTED
          album.draw_selected
        end
        index += 1
        count += 1
        y += 135
      end
    end
  end

  def draw_tracks
    if @genre == nil and !@create_mode
      x = 699
      y = 96
      @title.draw_text(" (" + @selecting_album.tracks.count.to_s + ")", WIDTH - 180, 20, ZOrder::UI, 1, 1, TEXT_COLOR)
      index = (@track_page - 1) * 10
      count = 0
      while index < @selecting_album.tracks.size && count < 10
        track = @selecting_album.tracks[index]
        track.x = x
        track.y = y
        track.draw

        case track.state
        when State::CLICKED, State::CLICKED + State::SELECTED
          track.draw_clicked
        when State::HOVERED, State::HOVERED + State::SELECTED
          track.draw_hovered
        when State::SELECTED
          track.draw_selected
        end
        index += 1
        count += 1
        y += 39
      end
    end
  end

  def draw_control
    # album control
    if !@create_mode
      @back_button_album.draw
      @next_button_album.draw
      @ui_font.draw_text(@album_page.to_s, 674/2, 608, ZOrder::UI, 1, 1, BLACK)
    else
      @back_button_playlist.draw
      @next_button_playlist.draw
      @ui_font.draw_text(@playlist_page.to_s, 674/2, 608, ZOrder::UI, 1, 1, BLACK)
    end

    # track control
    @back_button_track.draw
    @next_button_track.draw
    @ui_font.draw_text(@track_page.to_s, WIDTH-175, 608, ZOrder::UI, 1, 1, BLACK)

    # playback control
    @back_button_music.draw
    @next_button_music.draw
    @play_button.draw
  end

	# Draw detail of the currently playing song
  def draw_detail
    if @playing_song_index
      @playing_album.tracks[@playing_song_index].picture.draw(10, HEIGHT - 115, 100, 100)
      @detail_font_title.draw_text(@playing_album.title, 120, HEIGHT - 100, ZOrder::UI, 1, 1, BLACK)
      @detail_font.draw_text(@playing_album.tracks[@playing_song_index].title, 120, HEIGHT - 50, ZOrder::UI, 1, 1, BLACK)
    end
  end

	# Draw volume control
  def draw_vol
    @vol_down_button.draw
    @vol_up_button.draw
    @volume_display.draw(@volume)
  end

  # Draw Search and Create
  def draw_search
    @search_field.draw
    @search_button.draw
    @create_button.draw
    if @create_mode
      @cancel_button.draw
      @add_button.draw
    end
    if @create_mode && !@edit_mode
      @okay_button.draw
    elsif @edit_mode
      @confirm_button.draw
    end
    if @selecting_album && @selecting_album.title.include?("Playlist")
      @edit_button.draw
      @delete_button.draw
    end
  end

  # Draw Genre Choice Buttons
  def draw_genre
    @pop_button.draw
    @classic_button.draw
    @jazz_button.draw
    @rock_button.draw
    @various_button.draw
  end

  # Update function
  def update
    # Update Max Album Page
    @max_album_page = [(@albums.length / 4.0).ceil, 1].max

    # Next song when end if is playing
    if Gosu::Song.current_song.nil? && @playing_album && @playing_song_index && (!@create_mode && !@edit_mode)
      @playing_song_index += 1
      play_track(@playing_song_index, @playing_album)
    end

    # Album page handle
    if !@create_mode
      if @album_page == 1
        @back_button_album.state = State::INACTIVE
      elsif is_mouse_in(@back_button_album.x, @back_button_album.y, @back_button_album.x + @back_button_album.w, @back_button_album.y + @back_button_album.h)
        if button_down?(Gosu::MsLeft)
          if @back_button_album.state != State::CLICKED
            @back_button_album.state = State::CLICKED
            @album_page -= 1
          end
        else
          @back_button_album.state = State::HOVERED
        end
      else
        @back_button_album.state = State::NONE
      end

      if @album_page == @max_album_page
        @next_button_album.state = State::INACTIVE
      elsif is_mouse_in(@next_button_album.x, @next_button_album.y, @next_button_album.x + @next_button_album.w, @next_button_album.y + @next_button_album.h)
        if button_down?(Gosu::MsLeft)
          if @next_button_album.state != State::CLICKED
            @next_button_album.state = State::CLICKED
            @album_page += 1
          end
        else
          @next_button_album.state = State::HOVERED
        end
      else
        @next_button_album.state = State::NONE
      end
    end

    # Playlist page handle
    if @create_mode || @edit_mode || @added_tracks
      @max_playlist_page = @added_tracks.length == 0 ? 1 : (@added_tracks.length / 10.0).ceil

      if @playlist_page == 1
        @back_button_playlist.state = State::INACTIVE
      elsif is_mouse_in(@back_button_playlist.x, @back_button_playlist.y, @back_button_playlist.x + @back_button_playlist.w, @back_button_playlist.y + @back_button_playlist.h)
        if button_down?(Gosu::MsLeft)
          if @back_button_playlist.state != State::CLICKED
            @back_button_playlist.state = State::CLICKED
            @playlist_page -= 1
          end
        else
          @back_button_playlist.state = State::HOVERED
        end
      else
        @back_button_playlist.state = State::NONE
      end

      if @playlist_page == @max_playlist_page
        @next_button_playlist.state = State::INACTIVE
      elsif is_mouse_in(@next_button_playlist.x, @next_button_playlist.y, @next_button_playlist.x + @next_button_playlist.w, @next_button_playlist.y + @next_button_playlist.h)
        if button_down?(Gosu::MsLeft)
          if @next_button_playlist.state != State::CLICKED
            @next_button_playlist.state = State::CLICKED
            @playlist_page += 1
          end
        else
          @next_button_playlist.state = State::HOVERED
        end
      else
        @next_button_playlist.state = State::NONE
      end
    else
      @back_button_track.state = State::INACTIVE
      @next_button_playlist.state = State::INACTIVE
    end

    # Track page handle
    if @selecting_album != nil
      @max_track_page = @selecting_album.tracks.length == 0 ? 1 : (@selecting_album.tracks.length / 10.0).ceil

      if @track_page == 1
        @back_button_track.state = State::INACTIVE
      elsif is_mouse_in(@back_button_track.x, @back_button_track.y, @back_button_track.x + @back_button_track.w, @back_button_track.y + @back_button_track.h)
        if button_down?(Gosu::MsLeft)
          if @back_button_track.state != State::CLICKED
            @back_button_track.state = State::CLICKED
            @track_page -= 1
          end
        else
          @back_button_track.state = State::HOVERED
        end
      else
        @back_button_track.state = State::NONE
      end

      if @track_page == @max_track_page
        @next_button_track.state = State::INACTIVE
      elsif is_mouse_in(@next_button_track.x, @next_button_track.y, @next_button_track.x + @next_button_track.w, @next_button_track.y + @next_button_track.h)
        if button_down?(Gosu::MsLeft)
          if @next_button_track.state != State::CLICKED
            @next_button_track.state = State::CLICKED
            @track_page += 1
          end
        else
          @next_button_track.state = State::HOVERED
        end
      else
        @next_button_track.state = State::NONE
      end
    else
      @back_button_track.state = State::INACTIVE
      @next_button_track.state = State::INACTIVE
    end

    # Album state handle
    if !@create_mode
      visible_albums = @albums.slice((@album_page - 1) * 4, 4)
      visible_albums.each do |album|
        if is_mouse_in(20, album.y - 10, 620, album.y + 120)
          album.state = button_down?(Gosu::MsLeft) ? State::CLICKED : State::HOVERED

          if album.state == State::CLICKED
            @searched_album = nil
            @selecting_album = album
            @genre = nil
            @new_album = nil
            @track_page = 1
          end
        else
          album.state = (album == @selecting_album) ? State::SELECTED : State::NONE
        end
      end
    end

    # Track state handle
    if @selecting_album && @new_album.nil?
      @search_track = nil
      start_index = (@track_page - 1) * 10
      tracks_on_display = @selecting_album.tracks.slice(start_index, 10)
      tracks_on_display.length.times do |i|
        if is_mouse_in(tracks_on_display[i].x - PADDING, tracks_on_display[i].y - 6, tracks_on_display[i].x + 325, tracks_on_display[i].y + 30)
          if button_down?(Gosu::MsLeft)
            tracks_on_display[i].state = State::CLICKED + State::SELECTED
            if Gosu::Song.current_song != nil
              @song.stop
            end
            @playing_album = @selecting_album
            @playing_song_index = (@track_page-1)*10 + i
            play_track(@playing_song_index, @playing_album)
          else
            tracks_on_display[i].state = State::HOVERED + (tracks_on_display[i].state >= State::SELECTED ? State::SELECTED : 0)
          end
        elsif @playing_album != nil and @playing_album.tracks[@playing_song_index].title == tracks_on_display[i].title
          tracks_on_display[i].state = State::SELECTED
        else
          tracks_on_display[i].state = State::NONE
        end
      end
    end



    # Search Track handle
    if @search_track != nil
      start_index = (@track_page - 1) * 10
      tracks_on_display = @searched_album.tracks.slice(start_index, 10)
      tracks_on_display.length.times do |i|
        if is_mouse_in(tracks_on_display[i].x - PADDING, tracks_on_display[i].y - 6, tracks_on_display[i].x + 325, tracks_on_display[i].y + 30)
          if button_down?(Gosu::MsLeft)
            tracks_on_display[i].state = State::CLICKED + State::SELECTED
            if Gosu::Song.current_song != nil
              @song.stop
            end
            @playing_album = @searched_album
            @playing_song_index = (@track_page-1)*10 + i
            play_track(@playing_song_index, @playing_album)
          else
            tracks_on_display[i].state = State::HOVERED + (tracks_on_display[i].state >= State::SELECTED ? State::SELECTED : 0)
          end
        elsif @playing_album != nil and @playing_album.tracks[@playing_song_index].title == tracks_on_display[i].title
          tracks_on_display[i].state = State::SELECTED
        else
          tracks_on_display[i].state = State::NONE
        end
      end
    end

    # Genre Track state handle
    if @genre != nil and @tracks_by_genre != 0 and !@create_mode
      @search_track = nil
      start_index = (@track_page - 1) * 10
      tracks_on_display = @new_album.tracks.slice(start_index, 10)
      tracks_on_display.length.times do |i|
        if is_mouse_in(tracks_on_display[i].x - PADDING, tracks_on_display[i].y - 6, tracks_on_display[i].x + 325, tracks_on_display[i].y + 30)
          if button_down?(Gosu::MsLeft)
            tracks_on_display[i].state = State::CLICKED + State::SELECTED
            if Gosu::Song.current_song != nil
              @song.stop
            end
            @playing_album = @new_album
            @playing_song_index = (@track_page-1)*10 + i
            play_track(@playing_song_index, @playing_album)
          else
            tracks_on_display[i].state = State::HOVERED + (tracks_on_display[i].state >= State::SELECTED ? State::SELECTED : 0)
          end
        elsif @playing_album != nil and @playing_album.tracks[@playing_song_index].title == tracks_on_display[i].title
          tracks_on_display[i].state = State::SELECTED
        else
          tracks_on_display[i].state = State::NONE
        end
      end
    end

    # playback state handle
    if @playing_album != nil

      # back button handle
      if is_mouse_in(@back_button_music.x, @back_button_music.y, @back_button_music.x + @back_button_music.w, @back_button_music.y + @back_button_music.h)
        if button_down?(Gosu::MsLeft)
          if @back_button_music.state != State::CLICKED
            @back_button_music.state = State::CLICKED
            @playing_song_index -= 1
            play_track(@playing_song_index, @playing_album)
          end
        else
          @back_button_music.state = State::HOVERED
        end
      else
        @back_button_music.state = State::NONE
      end

      # next button handle
      if is_mouse_in(@next_button_music.x, @next_button_music.y, @next_button_music.x + @next_button_music.w, @next_button_music.y + @next_button_music.h)
        if button_down?(Gosu::MsLeft)
          if @next_button_music.state != State::CLICKED
            @next_button_music.state = State::CLICKED
            @playing_song_index += 1
            play_track(@playing_song_index, @playing_album)
          end
        else
          @next_button_music.state = State::HOVERED
        end
      else
        @next_button_music.state = State::NONE
      end

      # play button handle
      if is_mouse_in(@play_button.x, @play_button.y, @play_button.x + @play_button.w, @play_button.y + @play_button.h)
        if button_down?(Gosu::MsLeft)
          if @play_button.state != State::CLICKED
            @play_button.state = State::CLICKED
            @song.playing? ? @song.pause : @song.play
          end
        else
          @play_button.state = State::HOVERED
        end
      else
        @play_button.state = State::NONE
      end

      if @song.playing?
        @play_button.is_play = true
      else
        @play_button.is_play = false
      end

    else
      @back_button_music.state = State::INACTIVE
      @next_button_music.state = State::INACTIVE
      @play_button.state = State::INACTIVE
      @play_button.is_play = false
    end

    # handle volume down
    if is_mouse_in(@vol_down_button.x, @vol_down_button.y, @vol_down_button.x + @vol_down_button.w, @vol_down_button.y + @vol_down_button.h)
      if button_down?(Gosu::MsLeft)
        if @vol_down_button.state != State::CLICKED
          @vol_down_button.state = State::CLICKED
          @volume = (@volume - (@volume > 0 ? 0.1 : 0)).round(1)
          if Gosu::Song.current_song != nil
            @song.volume = @volume
          end
        end
      else
        @vol_down_button.state = State::HOVERED
      end
    else
      @vol_down_button.state = State::NONE
    end

    # handle volume up
    if is_mouse_in(@vol_up_button.x, @vol_up_button.y, @vol_up_button.x + @vol_up_button.w, @vol_up_button.y + @vol_up_button.h)
      if button_down?(Gosu::MsLeft)
        if @vol_up_button.state != State::CLICKED
          @vol_up_button.state = State::CLICKED
          @volume = (@volume + (@volume < 1 ? 0.1 : 0)).round(1)
          if Gosu::Song.current_song != nil
            @song.volume = @volume
          end
        end
      else
        @vol_up_button.state = State::HOVERED
      end
    else
      @vol_up_button.state = State::NONE
    end

    # handle caret
    @search_field.update_blink if text_input == @search_field

    # handle search button state
    if is_mouse_in(@search_button.x - PADDING, @search_button.y - PADDING, @search_button.x + @search_button.w + PADDING, @search_button.y + @search_button.h + PADDING)
      if button_down?(Gosu::MsLeft)
        if @search_button.state != State::CLICKED
          @search_button.state = State::CLICKED
        end
      else
        @search_button.state = State::HOVERED
      end
    else
      @search_button.state = State::NONE
    end

    ## handle genre button state start ##
    if is_mouse_in(@pop_button.x - PADDING, @pop_button.y - PADDING, @pop_button.x + @pop_button.w + PADDING, @pop_button.y + @pop_button.h + PADDING)
      if button_down?(Gosu::MsLeft)
        if @pop_button.state != State::CLICKED
          @pop_button.state = State::CLICKED
          if !@create_mode
            @searched_album = nil
            @track_page = 1
            @genre = Genre::POP
          end
        end
      else
        @pop_button.state = State::HOVERED
      end
    else
      @pop_button.state = State::NONE
    end
    if is_mouse_in(@classic_button.x - PADDING, @classic_button.y - PADDING, @classic_button.x + @classic_button.w + PADDING, @classic_button.y + @classic_button.h + PADDING)
      if button_down?(Gosu::MsLeft)
        if @classic_button.state != State::CLICKED
          @classic_button.state = State::CLICKED
          if !@create_mode
            @searched_album = nil
            @track_page = 1
            @genre = Genre::CLASSIC
          end
        end
      else
        @classic_button.state = State::HOVERED
      end
    else
      @classic_button.state = State::NONE
    end
    if is_mouse_in(@jazz_button.x - PADDING, @jazz_button.y - PADDING, @jazz_button.x + @jazz_button.w + PADDING, @jazz_button.y + @jazz_button.h + PADDING)
      if button_down?(Gosu::MsLeft)
        if @jazz_button.state != State::CLICKED
          @jazz_button.state = State::CLICKED
          if !@create_mode
            @searched_album = nil
            @track_page = 1
            @genre = Genre::JAZZ
          end
        end
      else
        @jazz_button.state = State::HOVERED
      end
    else
      @jazz_button.state = State::NONE
    end
    if is_mouse_in(@rock_button.x - PADDING, @rock_button.y - PADDING, @rock_button.x + @rock_button.w + PADDING, @rock_button.y + @rock_button.h + PADDING)
      if button_down?(Gosu::MsLeft)
        if @rock_button.state != State::CLICKED
          @rock_button.state = State::CLICKED
          if !@create_mode
            @searched_album = nil
            @track_page = 1
            @genre = Genre::ROCK
          end
        end
      else
        @rock_button.state = State::HOVERED
      end
    else
      @rock_button.state = State::NONE
    end
    if is_mouse_in(@various_button.x - PADDING, @various_button.y - PADDING, @various_button.x + @various_button.w + PADDING, @various_button.y + @various_button.h + PADDING)
      if button_down?(Gosu::MsLeft)
        if @various_button.state != State::CLICKED
          @various_button.state = State::CLICKED
          if !@create_mode
            @searched_album = nil
            @track_page = 1
            @genre = Genre::VARIOUS
          end
        end
      else
        @various_button.state = State::HOVERED
      end
    else
      @various_button.state = State::NONE
    end

    ## handle genre button state end ##
    
    # Create playlist button state handle
    if is_mouse_in(@create_button.x - PADDING, @create_button.y - PADDING, @create_button.x + @create_button.w + PADDING, @create_button.y + @create_button.h + PADDING)
      if button_down?(Gosu::MsLeft)
        if @create_button.state != State::CLICKED
          @create_button.state = State::CLICKED
          create_new_playlist
        end
      else
        @create_button.state = State::HOVERED
      end
    else
      @create_button.state = State::NONE
    end

    # Create button state handle
    if is_mouse_in(@okay_button.x - PADDING, @okay_button.y - PADDING, @okay_button.x + @okay_button.w + PADDING, @okay_button.y + @okay_button.h + PADDING) && !@edit_mode && @create_mode
      if button_down?(Gosu::MsLeft)
        if @okay_button.state != State::CLICKED
          @okay_button.state = State::CLICKED
          sleep(0.3)
          create_album
          @create_mode = false
          @selecting_album = nil
        end
      else
        @okay_button.state = State::HOVERED
      end
    else
      @okay_button.state = State::NONE
    end

    # Cancel button state handle
    if is_mouse_in(@cancel_button.x - PADDING, @cancel_button.y - PADDING, @cancel_button.x + @cancel_button.w + PADDING, @cancel_button.y + @cancel_button.h + PADDING) && (@create_mode || @edit_mode)
      if button_down?(Gosu::MsLeft)
        if @cancel_button.state != State::CLICKED
          @cancel_button.state = State::CLICKED
          sleep(0.3)
          @create_mode = false
          @edit_mode = false
          @selecting_album = nil
          @added_tracks.clear
        end
      else
        @cancel_button.state = State::HOVERED
      end
    else
      @cancel_button.state = State::NONE
    end

    # Add button state handle
    if is_mouse_in(@add_button.x - PADDING, @add_button.y - PADDING, @add_button.x + @add_button.w + PADDING, @add_button.y + @add_button.h + PADDING) && @create_mode
      if button_down?(Gosu::MsLeft)
        if @add_button.state != State::CLICKED
          @add_button.state = State::CLICKED
          add_track
        end
      else
        @add_button.state = State::HOVERED
      end
    else
      @add_button.state = State::NONE
    end

    # Edit button state handle
    if is_mouse_in(@edit_button.x - PADDING, @edit_button.y - PADDING, @edit_button.x + @edit_button.w + PADDING, @edit_button.y + @edit_button.h + PADDING) && @selecting_album != nil && @selecting_album.title.include?("Playlist")
      if button_down?(Gosu::MsLeft)
        if @edit_button.state != State::CLICKED
          @edit_button.state = State::CLICKED
          edit
        end
      else
        @edit_button.state = State::HOVERED
      end
    else
      @edit_button.state = State::NONE
    end

    # Confirm button state handle
    if is_mouse_in(@confirm_button.x - PADDING, @confirm_button.y - PADDING, @confirm_button.x + @confirm_button.w + PADDING, @confirm_button.y + @confirm_button.h + PADDING) && @create_mode && @edit_mode
      if button_down?(Gosu::MsLeft)
        if @confirm_button.state != State::CLICKED
          @confirm_button.state = State::CLICKED
          sleep(0.3)
          if @editing_album
            @editing_album.tracks = @added_tracks.map(&:dup)
            @editing_album = nil
            @added_tracks.clear
          end
          @create_mode = false
          @edit_mode = false
          @selecting_album = nil
        end
      else
        @confirm_button.state = State::HOVERED
      end
    else
      @confirm_button.state = State::NONE
    end

    # Delete button state handle
    if is_mouse_in(@delete_button.x - PADDING, @delete_button.y - PADDING, @delete_button.x + @delete_button.w + PADDING, @delete_button.y + @delete_button.h + PADDING) && @selecting_album != nil && @selecting_album.title.include?("Playlist")
      if button_down?(Gosu::MsLeft)
        if @delete_button.state != State::CLICKED
          @delete_button.state = State::CLICKED
          @albums.delete(@selecting_album)
          @selecting_album = nil
          @playlist = nil
          @added_tracks.clear
          @create_mode = false
          @edit_mode = false
          @selecting_album = nil
        end
      else
        @delete_button.state = State::HOVERED
      end
    else
      @delete_button.state = State::NONE
    end
  end

  # search field control
  def button_down(id)
    if !@edit_mode && !@create_mode
      if id == Gosu::MsLeft
        if is_mouse_in(@search_field.x - PADDING, @search_field.y - PADDING, @search_field.x + 200 + PADDING, @search_field.y + @font.height + PADDING) || is_mouse_in(@search_button.x - PADDING, @search_button.y - PADDING, @search_button.x + @search_button.w + PADDING, @search_button.y + @search_button.h + PADDING)
          if @search_field.text == ""
            self.text_input = @search_field
          elsif (id == Gosu::MsLeft && is_mouse_in(@search_button.x - PADDING, @search_button.y - PADDING, @search_button.x + @search_button.w + PADDING, @search_button.y + @search_button.h + PADDING))
            search(@search_field.text)
          end
        else
          self.text_input = nil
          @search_field.text = ""
        end
      elsif (id == Gosu::KbReturn && text_input == @search_field)
        search(@search_field.text)
      end
      super
    end
  end
  # Main draw function

  def draw
    draw_searched_track()
    draw_tracks_by_genre(@genre)
    draw_all_tracks()
    draw_genre()
    draw_search()
    draw_background()
    draw_albums()
    draw_control()
    draw_vol()
    if @selecting_album != nil
      draw_tracks()
    end
    if @playing_album != nil
      draw_detail()
    end
  end

  def needs_cursor?; true; end

end

MusicPlayerMain.new.show if __FILE__ == $0
