require 'gosu'

def draw_oval(x, y, xradius, yradius, color, z)
  cenx = x + xradius
  ceny = y + yradius

  for deg in 0..90
    rad = deg.to_f * 2.0 * Math::PI / 360.0

    x = Math.cos(rad) * xradius
    y = Math.sin(rad) * yradius

    x1 = cenx - x
    y1 = ceny - y

    x2 = cenx - x
    y2 = ceny + y

    x3 = cenx + x
    y3 = ceny - y

    x4 = cenx + x
    y4 = ceny + y

    Gosu.draw_quad(x1, y1, color, x2, y2, color, x3, y3, color, x4, y4, color, z)
  end
end

def draw_circle(x, y, radius, color, z)
  cenx = x + radius
  ceny = y + radius

  for deg in 0..90
    rad = deg.to_f * 2.0 * Math::PI / 360.0

    x = Math.cos(rad) * radius
    y = Math.sin(rad) * radius

    x1 = cenx - x
    y1 = ceny - y

    x2 = cenx - x
    y2 = ceny + y

    x3 = cenx + x
    y3 = ceny - y

    x4 = cenx + x
    y4 = ceny + y

    Gosu.draw_quad(x1, y1, color, x2, y2, color, x3, y3, color, x4, y4, color, z)
  end
end

# class Win < Gosu::Window
#   def initialize
#     super 500, 500
#   end

#   def draw
#     draw_oval(50, 50, 200, 200, 0xff_123456, 0)
#   end
# end

# Win.new.show
