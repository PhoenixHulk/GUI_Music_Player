require './modules'

class ArtWork
  attr_accessor :bmp

  def initialize (file)
    @bmp = Gosu::Image.new(file)
  end

  def draw(x, y, w, h)
    @bmp.draw_as_quad(x, y, Gosu::Color::WHITE, x+w, y, Gosu::Color::WHITE, x, y+h, Gosu::Color::WHITE, x+w, y+h, Gosu::Color::WHITE, ZOrder::UI)
  end
end