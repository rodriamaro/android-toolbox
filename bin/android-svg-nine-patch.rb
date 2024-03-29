#!/usr/bin/ruby -w
#
# android-svg-nine-patch - Create Android NinePatch images from SVGs
# Copyright (C) 2011  Lorenzo Villani
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Usage:
# scalable-nine-patch.rb input output x y
#
# The input SVG _MUST_ contain four paths with the following IDs:
# - padding-x
# - padding-y
# - stretch-x
# - stretch-y
#
# They can be placed anywhere in the canvas (preferably outside) and the stroke
# must be at least one pixel wide.

require "rubygems"
require "RMagick"
require "nokogiri"

include Magick

# ------------------------------------------------------------------------------
# Classes
# ------------------------------------------------------------------------------

class Path
  attr_accessor :x, :y, :width, :height
end

class Svg
  def initialize(path)
    @svg = Nokogiri::XML(open(path))

    @path = path
    @height = @svg.root.attribute("height").value().to_i()
    @width = @svg.root.attribute("width").value().to_i()
  end

  def path()
    return @path
  end

  def padding_x()
    return get_path("padding-x")
  end

  def padding_y()
    return get_path("padding-y")
  end

  def stretch_x()
    return get_path("stretch-x")
  end

  def stretch_y()
    return get_path("stretch-y")
  end

  def height()
    return @height
  end

  def width()
    return @width
  end

  # ----------------------------------------------------------------------------
  # "Private" Methods
  # ----------------------------------------------------------------------------

  def get_path(name)
    path = @svg.xpath("//svg:svg/svg:path[@id='#{name}']")

    return deconstruct_path_attributes(path.attribute("d").value())
  end

  def deconstruct_path_attributes(attributes_string)
    path = Path.new

    if attributes_string =~ /[mM] -?(\d+(\.\d+)?),-?(\d+(\.\d+)?) -?(\d+(\.\d+)?),-?(\d+(\.\d+)?)/ then
      path.x = $1.to_i()
      path.y = $3.to_i()
      path.width = $5.to_i()
      path.height = $7.to_i()
    end

    return path
  end
end

class ScaledSvg
  def initialize(svg, width, height)
    @svg = svg
    @width = width
    @height = height
    @scale_ratio_x = @width.to_f() / svg.width().to_f()
    @scale_ratio_y = @height.to_f() / svg.height().to_f()
  end

  def padding_x()
    return scale(@svg.padding_x())
  end

  def padding_y()
    return scale(@svg.padding_y())
  end

  def stretch_x()
    return scale(@svg.stretch_x())
  end

  def stretch_y()
    return scale(@svg.stretch_y())
  end

  def scale_ratio_x()
    return @scale_ratio_x
  end

  def scale_ratio_y()
    return @scale_ratio_y
  end

  def height()
    return @height
  end

  def width()
    return @width
  end

  # ----------------------------------------------------------------------------
  # "Private" Methods
  # ----------------------------------------------------------------------------

  def scale(what)
    what.x *= @scale_ratio_x
    what.y *= @scale_ratio_y
    what.width *= @scale_ratio_x
    what.height *= @scale_ratio_y

    return what
  end
end

# ------------------------------------------------------------------------------
# Methods
# ------------------------------------------------------------------------------

def create_scaled_svg(path, width, height)
  svg = Svg.new(path)

  return ScaledSvg.new(svg, width, height)
end

def inkscape_export_svg(svg, input, output)
  `inkscape -z -C -w #{svg.width()} -h #{svg.height()} -e #{output} #{input}`
end

def rmagick_with_picture(path)
  picture = ImageList.new(path).at(0)
  picture.background_color = "None"

  p = yield picture

  if p.instance_of? Image then
    picture = p
  end

  picture.write(path)
end

def rmagick_extend_border(input)
  rmagick_with_picture(input) do |picture|
    next picture.extent(picture.columns + 2, picture.rows + 2, 1, 1)
  end
end

def rmagick_add_guides(scaled_svg, input)
  rmagick_with_picture(input) do |picture|
    draw = Draw.new
    draw.stroke('black')
    draw.stroke_antialias(false)
    draw.stroke_width(1)

    rmagick_draw_top_line(draw, scaled_svg.stretch_x.x, scaled_svg.stretch_x.width)
    rmagick_draw_left_line(draw, scaled_svg.stretch_y.y, scaled_svg.stretch_y.height)
    rmagick_draw_bottom_line(picture, draw, scaled_svg.padding_x.x, scaled_svg.padding_x.width)
    rmagick_draw_right_line(picture, draw, scaled_svg.padding_y.y, scaled_svg.padding_y.height)

    draw.draw(picture)
  end
end

def rmagick_draw_top_line(draw, x, length)
  draw.line(x, 0, x + length, 0)
end

def rmagick_draw_bottom_line(picture, draw, x, length)
  draw.line(x, picture.rows - 1, x + length, picture.rows - 1)
end

def rmagick_draw_left_line(draw, y, length)
  draw.line(0, y, 0, y + length)
end

def rmagick_draw_right_line(picture, draw, y, length)
  draw.line(picture.columns - 1, y, picture.columns - 1, y + length)
end

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

if __FILE__ == $PROGRAM_NAME then
  path_input = ARGV[0]
  path_output = ARGV[1]
  exported_width = ARGV[2]
  exported_height = ARGV[3]

  if path_input == nil or path_output == nil or exported_width == nil or exported_height == nil then
    puts "Usage: #{$PROGRAM_NAME} <input svg> <output svg> <exported width> <exported height>"

    exit 1
  end

  scaled_svg = create_scaled_svg(path_input, exported_width.to_i(), exported_height.to_i())

  inkscape_export_svg(scaled_svg, path_input, path_output)
  rmagick_extend_border(path_output)
  rmagick_add_guides(scaled_svg, path_output)
end

