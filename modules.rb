require 'rubygems'
require 'gosu'

module ZOrder
  BACKGROUND, MID, UI = *0..2
end

module Genre
  VARIOUS, POP, CLASSIC, JAZZ, ROCK = *0..4
end

module State
  NONE, INACTIVE, HOVERED, CLICKED, SELECTED = *0..4
end

HEIGHT = 768
WIDTH = 1024

TOP_BG_COLOR = Gosu::Color.new(0xFF_FFFE91)
BOTTOM_BG_COLOR = Gosu::Color.new(0xFF_ADFFFA)
CONTROL_BAR_COLOR = Gosu::Color.new(0xFF_6B85FF)

TEXT_COLOR = Gosu::Color.new(0xFF_8E403A)
UI_COLOR = Gosu::Color::WHITE
UI_INACTIVE_COLOR = Gosu::Color::new(0x10_000000)
UI_HOVERED_COLOR = Gosu::Color.new(0x7F_FFFFFF)
UI_CLICKED_COLOR = Gosu::Color.new(0x4C_999999)
UI_SELECTED_COLOR = Gosu::Color.new(0xFF_71B4B5)

INACTIVE_COLOR = 0xFF_333333
ACTIVE_COLOR = Gosu::Color::WHITE
SELECTION_COLOR = Gosu::Color::WHITE
CARET_COLOR = Gosu::Color::BLUE
PLACEHOLDER_COLOR = Gosu::Color::WHITE
PADDING = 5

BLACK = Gosu::Color::BLACK

GENRE_NAMES = ['Various', 'Pop', 'Classic', 'Jazz', 'Rock', 'Hip Hop']
