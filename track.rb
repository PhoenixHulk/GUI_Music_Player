require './modules'

class Track
  attr_accessor :title, :location, :picture, :x, :y, :state

  def initialize(title, location, picture)
    @title = title
    @location = location
		@picture = picture

    @font_normal = Gosu::Font.new(20, name: "Times New Roman")
    @font_playing = Gosu::Font.new(23, bold: true, name: "Times New Roman")
    @small_normal = Gosu::Font.new(18, name: "Times New Roman")
    @small_playing = Gosu::Font.new(19, bold: true, name: "Times New Roman")

    @x = @y = 0

    @state = State::NONE
  end

  def dup
    copy = super
    copy.x = 0
    copy.y = 0
    copy.state = State::NONE
    copy
  end

  def draw
    if @state < State::SELECTED
      text_width = @font_normal.text_width(@title)
      if text_width < 320
        @font_normal.draw_text(@title, x, y, ZOrder::UI, 1, 1, BLACK)
      else
        @small_normal.draw_text(@title, x, y, ZOrder::UI, 1, 1, BLACK)
      end
    else
      text_width = @font_playing.text_width(@title)
      if text_width < 320
        @font_playing.draw_text(@title, x, y, ZOrder::UI, 1, 1, BLACK)
      else
        @small_playing.draw_text(@title, x, y, ZOrder::UI, 1, 1, BLACK)
      end
    end

    case @state
    when State::CLICKED, State::CLICKED + State::SELECTED
      draw_clicked
    when State::HOVERED, State::HOVERED + State::SELECTED
      draw_hovered
    when State::SELECTED
      draw_selected
    end
  end

  def draw_hovered
    Gosu.draw_rect(@x - PADDING, @y - 6, 325, 35, 0x33_000000, ZOrder::MID)
  end

  def draw_clicked
    Gosu.draw_rect(@x - PADDING, @y - 6, 325, 35, 0x4b_000000, ZOrder::MID)
  end

  def draw_selected
    Gosu.draw_rect(@x - PADDING, @y - 6, 325, 35, UI_SELECTED_COLOR, ZOrder::MID)
  end
end