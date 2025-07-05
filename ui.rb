require './modules'
require './circle'

class NextButton
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y, w, h)
    @w = w
    @h = h
    @x = x
    @y = y
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::INACTIVE
      color = UI_INACTIVE_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State::CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_triangle(@x+@w, @y+(@h/2).to_i, color, @x, @y, color, @x, @y+@h, color, ZOrder::UI)
  end
end

class BackButton
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y, w, h)
    @w = w
    @h = h
    @x = x
    @y = y
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::INACTIVE
      color = UI_INACTIVE_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State::CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_triangle(@x, @y+(@h/2).to_i, color, @x+@w, @y, color, @x+@w, @y+@h, color, ZOrder::UI)
  end
end

class NextSong
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y, w, h)
    @w = w
    @h = h
    @x = x
    @y = y
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::INACTIVE
      color = UI_INACTIVE_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State::CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_triangle(@x+@w, @y+(@h/2).to_i, color, @x, @y, color, @x, @y+@h, color, ZOrder::UI)
    Gosu.draw_rect(@x+@w, @y, 5, @h, color, ZOrder::UI)
  end
end

class PreviousSong
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y, w, h)
    @w = w
    @h = h
    @x = x
    @y = y
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::INACTIVE
      color = UI_INACTIVE_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State::CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_triangle(@x, @y+(@h/2).to_i, color, @x+@w, @y, color, @x+@w, @y+@h, color, ZOrder::UI)
    Gosu.draw_rect(@x-5, @y, 5, @h, color, ZOrder::UI)
  end
end

class PlayButton
  attr_accessor :x, :y, :w, :h, :state, :is_play

  def initialize(x, y)
    @x = x
    @y = y
    @w = @h = 49
    @state = State::NONE
    @is_play = false
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::INACTIVE
      color = UI_INACTIVE_COLOR
    when State::HOVERED
      color = 0xFF_8A94A9
    when State::CLICKED
      color = 0xFF_3C4A67
    end
    draw_circle(@x, @y, 24, color, ZOrder::UI)

    if not @is_play
      Gosu.draw_triangle(@x+16, @y+12, CONTROL_BAR_COLOR, @x+16, @y+37, CONTROL_BAR_COLOR, @x+34, @y+24, CONTROL_BAR_COLOR, ZOrder::UI)
    else
      Gosu.draw_rect(@x+13, @y+12, 8, 25, CONTROL_BAR_COLOR, ZOrder::UI)
      Gosu.draw_rect(@x+28, @y+12, 8, 25, CONTROL_BAR_COLOR, ZOrder::UI)
    end
  end
end

class VolUpButton
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y)
    @x = x
    @y = y
    @w = @h = 30
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = 0xFF_8A94A9
    when State::CLICKED
      color = 0xFF_3C4A67
    end

    Gosu.draw_rect(@x+11, @y, 8, 30, color, ZOrder::UI)
    Gosu.draw_rect(@x, @y+11, 30, 8, color, ZOrder::UI)
  end
end

class VolDownButton
  attr_accessor :x, :y, :w, :h, :state

  def initialize(x, y)
    @x = x
    @y = y
    @w = 30
    @h = 8
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State::CLICKED
      color = UI_CLICKED_COLOR
    end

    Gosu.draw_rect(@x, @y, @w, @h, color, ZOrder::UI)
  end
end

class Volume
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def draw(vol)
    vol = (vol * 10).to_i
    for i in 1..10
      if i <= vol
        color = UI_COLOR
      else
        color = UI_CLICKED_COLOR
      end
      Gosu.draw_rect(x + (i-1)*10, y + 40-i*4, 5, i*4, color, ZOrder::UI)
    end
  end
end

class TextField < Gosu::TextInput
  attr_reader :x, :y, :placeholder

  def initialize(window, font, x, y, w, h, placeholder = "Search tracks...")
    super()
    @window, @font, @x, @y, @w, @h = window, font, x, y, w, h
    @placeholder = placeholder
    self.text = ""
    @blink_timer = 0
    @show_caret = true
  end

  def draw
    active = @window.text_input == self
    bg_color = active ? ACTIVE_COLOR : INACTIVE_COLOR
    display_text = text.empty? && !active ? placeholder : text
    text_color = text.empty? && !active ? PLACEHOLDER_COLOR : BLACK

    Gosu.draw_rect(x - PADDING, y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, bg_color, ZOrder::UI)

    # Draw selection
    if selection_start != caret_pos
      sel_start = [selection_start, caret_pos].min
      sel_end = [selection_start, caret_pos].max
      sel_x = x + @font.text_width(text[0...sel_start])
      sel_width = @font.text_width(text[sel_start...sel_end])
      Gosu.draw_rect(sel_x, y, sel_width, @h, SELECTION_COLOR, ZOrder::UI)
    end

    # Draw text or placeholder
    @font.draw_text(display_text, x, y, ZOrder::UI, 1, 1, text_color)

    # Draw caret
    if active && @show_caret
      caret_x = x + @font.text_width(text[0...caret_pos])
      Gosu.draw_line(caret_x, y, CARET_COLOR, caret_x, y + @h, CARET_COLOR, ZOrder::UI)
    end
  end

  def update_blink
    @blink_timer += 1
    if @blink_timer >= 30  # Adjust for blink speed (30 frames ~ 0.5 sec at 60 FPS)
      @show_caret = !@show_caret
      @blink_timer = 0
    end
  end

  def update
    @search_field.update_blink if text_input == @search_field
  end
end

class SearchButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(20)
    @w = w
    @h = @font.height
    @text = "Search"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State:: CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end


class PopButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(20)
    @w = w
    @h = @font.height
    @text = "Pop"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State:: CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class ClassicButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(20)
    @w = w
    @h = @font.height
    @text = "Classic"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State:: CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class JazzButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(20)
    @w = w
    @h = @font.height
    @text = "Jazz"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State:: CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class RockButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(20)
    @w = w
    @h = @font.height
    @text = "Rock"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State:: CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class VariousButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(20)
    @w = w
    @h = @font.height
    @text = "Various"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = UI_HOVERED_COLOR
    when State:: CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class CreatePlaylistButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(20, bold: true)
    @w = w
    @h = @font.height
    @text = "+ Create Playlist"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = Gosu::Color::GRAY
    when State:: CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class OkayButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(30, bold: true)
    @w = w
    @h = @font.height
    @text = "Create"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = Gosu::Color::GREEN
    when State::HOVERED
      color = Gosu::Color::GRAY
    when State:: CLICKED
      color = UI_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class CancelButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(30, bold: true)
    @w = w
    @h = @font.height
    @text = "Cancel"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = Gosu::Color::RED
    when State::HOVERED
      color = Gosu::Color::GRAY
    when State:: CLICKED
      color = UI_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class AddButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(30, bold: true)
    @w = w
    @h = @font.height
    @text = "Add"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = Gosu::Color::GRAY
    when State::HOVERED
      color = Gosu::Color.new(0xFF_DDDD00)
    when State:: CLICKED
      color = UI_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class EditButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(20, bold: true)
    @w = w
    @h = @font.height
    @text = "Edit"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = UI_COLOR
    when State::HOVERED
      color = Gosu::Color::GRAY
    when State:: CLICKED
      color = UI_CLICKED_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class ConfirmButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(30, bold: true)
    @w = w
    @h = @font.height
    @text = "Save"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = Gosu::Color::GREEN
    when State::HOVERED
      color = Gosu::Color::GRAY
    when State:: CLICKED
      color = UI_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end

class DeleteButton
  attr_accessor :x, :y, :w, :h, :state
  
  def initialize(x, y, w)
    @x = x
    @y = y
    @font = Gosu::Font.new(20, bold: true)
    @w = w
    @h = @font.height
    @text = "Delete"
    @state = State::NONE
  end

  def draw
    case @state
    when State::NONE
      color = Gosu::Color::RED
    when State::HOVERED
      color = Gosu::Color::GRAY
    when State:: CLICKED
      color = UI_COLOR
    end
    Gosu.draw_rect(@x - PADDING, @y - PADDING, @w + 2 * PADDING, @h + 2 * PADDING, color, ZOrder::UI)
    @font.draw_text(@text, @x, @y, ZOrder::UI, 1, 1, BLACK)
  end
end