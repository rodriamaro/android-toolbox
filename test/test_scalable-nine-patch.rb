#!/usr/bin/ruby -w
#
# test_scalable-nine-patch.rb - Test scalable-nine-patch.rb
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

require "rubygems"
require "test/unit"

require "scalable-nine-patch"

# ------------------------------------------------------------------------------
# Classes
# ------------------------------------------------------------------------------

class TestNinePatch < Test::Unit::TestCase
  def setup()
    @svg = Svg.new("test/svg/reference.svg")
  end

  def test_deconstruct_path_attributes()
    # padding-x
    result = @svg.deconstruct_path_attributes("m 188.13559,895.25424 440.67797,0")

    assert_equal(188, result.x)
    assert_equal(895, result.y)
    assert_equal(440, result.width)
    assert_equal(0, result.height)

    # padding-y
    result = @svg.deconstruct_path_attributes("m 900.15139,130.10169 0,579.66102")

    assert_equal(900, result.x)
    assert_equal(130, result.y)
    assert_equal(0, result.width)
    assert_equal(579, result.height)
  end

  def test_canvas_size()
    assert_equal(864, @svg.width)
    assert_equal(864, @svg.height)
  end

  def test_padding_x()
    padding_x = @svg.padding_x

    assert_equal(188, padding_x.x)
    assert_equal(895, padding_x.y)
    assert_equal(440, padding_x.width)
    assert_equal(0, padding_x.height)
  end

  def test_padding_y()
    padding_y = @svg.padding_y

    assert_equal(900, padding_y.x)
    assert_equal(130, padding_y.y)
    assert_equal(0, padding_y.width)
    assert_equal(579, padding_y.height)
  end

  def test_scale_half()
    scaled = ScaledSvg.new(@svg, 432, 432)

    assert_equal(94, scaled.padding_x().x)
    assert_equal(220, scaled.padding_x().width)

    assert_equal(0.5, scaled.scale_ratio_x())
    assert_equal(0.5, scaled.scale_ratio_y())

    assert_equal(432, scaled.height())
    assert_equal(432, scaled.width())
  end
end
