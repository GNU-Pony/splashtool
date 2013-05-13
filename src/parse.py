#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# splashtool – A simple tool for creating SYSLINUX splashes without fuss
# 
# Copyright © 2013  Mattias Andrée (maandree@member.fsf.org)
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


timeout = 0
title = ''
background = 'splash.png'
font = '/usr/share/kbd/consolefonts/default8x16.psfu.gz'
helptext = ''
labels = ''
width = 60
margin = 3
rows = 12
vshift = 0
timeoutrow = 18
tabmsgrow = 18
helpmsgrow = 22
helpmsgendrow = 29
colour_border = '#ff808080#00000000'
colour_title = '#ffffffff#00000000'
colour_sel = '#ff808080#ffd0a290'
colour_unsel = '#ffffffff#00000000'
colour_help = '#ffffffff#00000000'
colour_timeout_msg = '#ffffff00#00000000'
colour_timeout = '#ffffff00#00000000'
colour_tabmsg = '#ffffff00#00000000'


while True:
    try:
        line = input()
        
    except:
        break


border = colour_border

labels = (labels + '\n' * rows).split('\n')[:rows]
labels = [(' ' + x + ' ' * width)[:width - 2] + '\033\033' for x in labels]
labels = ['\033' + (colour_sel if x is labels[0] else colour_unsel) + '\033' + x for x in labels]

title = '\033' + colour_title + '\033' + ' ' * ((width - len(title)) // 2) + title + ' ' * width + '\033\033'

helpmsgendrow -= vshift
helptext = (helptext + '\n' * (helpmsgendrow - helpmsgrow)).split('\n')[: helpmsgendrow - helpmsgrow + 1]
helptext = ['\033' + colour_help + '\033' + (x + ' ' * 86)[:86] + '\033\033' for x in helptext]
helptext = '\n'.join(helptext)

text = '\n' * vshift + ' ' * margin + '\033' + border + '\033┌' + '─' * width + '┐\033\033\n'
text += ' ' * margin + '\033' + border + '\033│\033\033' + title + '\033' + border + '\033│\033\033\n'
text += ' ' * margin + '\033' + border + '\033├' + '─' * width + '┤\033\033\n'
for label in labels:
    text += ' ' * margin + '\033' + border + '\033│\033\033' + label + '\033' + border + '\033│\033\033\n'
text += ' ' * margin + '\033' + border + '\033└' + '─' * width + '┘\033\033\n'

more = []

if timeout > 0:
    timeoutmsg = 'Automatic boot in %i seconds' % (timeout // 10)
    timeoutmsg = (86 - len(timeoutmsg)) // 2
    timeoutmsg = ' ' * timeoutmsg + '\033%s\033Automatic boot in \033%s\033%i\033%s\033 seconds...\033\033'
    timeoutmsg %= (colour_timeout_msg, colour_timeout, timeout // 10, colour_timeout_msg)
    more.append((timeoutrow * 10 + 0, timeoutmsg))
tabmsg = 'Press [Tab] to edit options'
tabmsg = ' ' * ((86 - len(tabmsg)) // 2) + tabmsg
more.append((tabmsgrow * 10 + 1, '\033%s\033%s\033\033' % (colour_tabmsg, tabmsg)))
more.append((helpmsgrow * 10 + 2, helptext))

more = [(x[0] // 10, x[1]) for x in sorted(more, key = lambda x : x[0])]
line = len(text.split('\n'))

for seg in more:
    if (line <= seg[0]):
        text += '\n' * (seg[0] - line) + seg[1] + '\n'
        line = seg[0] + len(seg[1].split('\n'))

text = background + '\n' + font + '\n' + '\n'.join((text + '\n' * 30).split('\n')[:30])

print(text, end = '')
