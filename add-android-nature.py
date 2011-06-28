#!/usr/bin/env python
#
# Copyright (c) 2011 Lorenzo Villani
# Adds Android project nature to existing Eclipse projects.
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
#
# How to use:
# 1) run add-android-nature.py inside your project directory
# 2) refresh your project in Eclipse
# 3) right click your project then click on "Android Tools" -> "Fix project properties"

from xml.dom.minidom import parse, parseString, Element, Text

import os
import sys

ECLIPSE_CLASSPATH = '.classpath'
ECLIPSE_PROJECT = '.project'
ECLIPSE_ANDROID_NATURE = 'com.android.ide.eclipse.adt.AndroidNature'
ECLIPSE_ADT_AAPT = 'com.android.ide.eclipse.adt.ResourceManagerBuilder'
ECLIPSE_ADT_PRECOMPILER = 'com.android.ide.eclipse.adt.PreCompilerBuilder'


def has_classpath_entry():
    """
    Determines if we already have a correct classpath entry.
    """
    dom = parse(ECLIPSE_CLASSPATH)

    entries = dom.getElementsByTagName('classpathentry')

    for entry in entries:
        if entry.getAttribute('path') == 'gen/':
            return True
    else:
        return False


def has_nature(dom):
    """
    Determines if this project already has an Android nature.
    """
    natures = map(lambda e: e.firstChild.nodeValue,
                  dom.getElementsByTagName('nature'))

    if ECLIPSE_ANDROID_NATURE in natures:
        return True
    else:
        return False


def add_android_nature(dom):
    """
    Adds Android nature to this Eclipse project.
    """
    nature_value = dom.createTextNode(ECLIPSE_ANDROID_NATURE)

    nature = dom.createElement('nature')
    nature.appendChild(nature_value)

    dom.getElementsByTagName('natures')[0].appendChild(nature)


# def add_build_commands(dom):
#     """
#     Adds ADT build commands to this Eclipse project.
#     """
#     build_spec = dom.getElementsByTagName('buildSpec')[0]
#
#     for builder in [ECLIPSE_ADT_AAPT, ECLIPSE_ADT_PRECOMPILER]:
#         args = dom.createTextNode('')
#         command = dom.createTextNode(builder)
#
#         command_args = dom.createElement('arguments')
#         command_args.appendChild(args)
#
#         command_name = dom.createElement('name')
#         command_name.appendChild(command)
#
#         build_command = dom.createElement('buildCommand')
#         build_command.appendChild(command_name)
#         build_command.appendChild(command_args)
#
#         build_spec.insertBefore(build_command, build_spec.firstChild)


def add_classpath_entry():
    dom = None

    with open(ECLIPSE_CLASSPATH, 'r') as classpath:
        dom = parseString(classpath.read())

    with open(ECLIPSE_CLASSPATH, 'w') as classpath:
        classpath_entry = dom.createElement('classpathentry')
        classpath_entry.setAttribute('kind', 'src')
        classpath_entry.setAttribute('path', 'gen/')

        dom.getElementsByTagName('classpath')[0].appendChild(classpath_entry)
        dom.writexml(classpath)


if __name__ == '__main__':
    if os.path.exists(ECLIPSE_PROJECT):
        dom = None

        with open(ECLIPSE_PROJECT, 'r') as project_file:
            dom = parseString(project_file.read())

        # Process
        with open(ECLIPSE_PROJECT, 'r+') as project_file:
            if not has_nature(dom):
                # add_build_commands(dom)
                add_android_nature(dom)

                dom.writexml(project_file, encoding='UTF-8')
            else:
                print "This Eclipse project already has an Android nature"

            if not has_classpath_entry():
                add_classpath_entry()
            else:
                print "This Eclipse project already has a valid classpath"
    else:
        print "Error: missing Eclipse .project file"
        sys.exit(1)
