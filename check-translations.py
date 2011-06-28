#!/usr/bin/env python
#
# Copyright (c) 2011 Lorenzo Villani
#
# Makes sure that all translated strings.xml entries are synchronized with ones
# from default language.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from xml.dom.minidom import parse

import sys

if __name__ == '__main__':
    default = parse('res/values/strings.xml')
    default_lang = set()

    for string in default.getElementsByTagName('string'):
        default_lang.add(string.getAttribute('name'))

    for arg in sys.argv[1:]:
        lang = parse(arg)
        lang_set = set()

        for string in lang.getElementsByTagName('string'):
            lang_set.add(string.getAttribute('name'))

        missing_translations = default_lang.difference(lang_set)
        superflous_tranlations = lang_set.difference(default_lang)

        print 'Report for %s:' % arg

        print 'Missing translations:'
        for missing in missing_translations:
            print '   %s' % missing

        print 'Superfluous translations:'
        for superfluous in superflous_tranlations:
            print '   %s' % superfluous
