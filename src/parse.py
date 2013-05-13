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

import os
import sys


DEBUG = False


timeout = 0
title = ''
background = 'splash.png'
font = '/usr/share/kbd/consolefonts/default8x16.psfu.gz'
helptext = ''
labels = ''
width = 78
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


texthelp = False
while True:
    try:
        line = input()
        orig = line
        while '  ' in line:
            line = line.replace('  ', ' ')
        line = line.split(' ')
        line[0] = line[0].lower()
        if (line[0] == 'endtext') and (len(line) == 1):
            texthelp = False
        elif texthelp:
            helptext += orig + '\n'
        elif line[0] == 'text':
            texthelp = True
        elif line[0] == 'timeout':
            timeout = int(line[1])
        elif line[0] == 'menu':
            line[1] = line[1].lower()
            if line[1] == 'title':            title = line[2]
            elif line[1] == 'background':     background = line[2]
            elif line[1] == 'font':           font = line[2]
            elif line[1] == 'width':          width = int(line[2])
            elif line[1] == 'height':         height = int(line[2])
            elif line[1] == 'margin':         margin = int(line[2])
            elif line[1] == 'rows':           rows = int(line[2])
            elif line[1] == 'vshift':         vshift = int(line[2])
            elif line[1] == 'timeoutrow':     timeoutrow = int(line[2])
            elif line[1] == 'tabmsgrow':      tabmsgrow = int(line[2])
            elif line[1] == 'helpmsgrow':     helpmsgrow = int(line[2])
            elif line[1] == 'helpmsgendrow':  helpmsgendrow = int(line[2])
            elif line[1] == 'color':
                colour = line[4] + line[5]
                if line[2] == 'border':
                    colour_border = colour
                elif line[2] == 'title':
                    colour_title = colour
                elif line[2] == 'sel':
                    colour_sel = colour
                elif line[2] == 'unsel':
                    colour_unsel = colour
                elif line[2] == 'help':
                    colour_help = colour
                elif line[2] == 'timeout_msg':
                    colour_timeout_msg = colour
                elif line[2] == 'timeout':
                    colour_timeout = colour
                elif line[2] == 'tabmag':
                    colour_tabmsg = colour
            elif line[1] == 'label':
                line = orig[orig.lower().find('label') + 6:]
                while line.startswith(' '):
                    line = line[1:]
                labels += line + '\n'
    except:
        break


if DEBUG:
    colour_border = ''
    colour_title = ''
    colour_sel = ''
    colour_unsel = ''
    colour_help = ''
    colour_timeout_msg = ''
    colour_timeout = ''
    colour_tabmsg = ''


border = colour_border

labels = (labels + '\n' * rows).split('\n')[:rows]
labels = [(' ' + x + ' ' * 68)[:68] + '\033\033' for x in labels]
labels = ['\033' + (colour_sel if x is labels[0] else colour_unsel) + '\033' + x for x in labels]

title = (' ' * ((68 - len(title)) // 2) + title + ' ' * 68)[:68]
title = '\033' + colour_title + '\033' + title + '\033\033'

helpmsgendrow -= vshift
helptext = (helptext + '\n' * (helpmsgendrow - helpmsgrow + 1)).split('\n')[: helpmsgendrow - helpmsgrow + 1]
helptext = ['\033' + colour_help + '\033' + (' ' * margin + x + ' ' * width)[:width] + '\033\033' for x in helptext]
helptext = '\n'.join(helptext)

menumargin = (width - 70) // 2
text = '\n' * vshift + ' ' * menumargin + '\033' + border + '\033┌' + '─' * 68 + '┐\033\033\n'
text += ' ' * menumargin + '\033' + border + '\033│\033\033' + title + '\033' + border + '\033│\033\033\n'
text += ' ' * menumargin + '\033' + border + '\033├' + '─' * 68 + '┤\033\033\n'
for label in labels:
    text += ' ' * menumargin + '\033' + border + '\033│\033\033' + label + '\033' + border + '\033│\033\033\n'
text += ' ' * menumargin + '\033' + border + '\033└' + '─' * 68 + '┘\033\033\n'

more = []

if timeout > 0:
    timeoutmsg = 'Automatic boot in %i seconds' % (timeout // 10)
    timeoutmsg = (width - len(timeoutmsg)) // 2
    timeoutmsg = ' ' * timeoutmsg + '\033%s\033Automatic boot in \033%s\033%i\033%s\033 seconds...\033\033'
    timeoutmsg %= (colour_timeout_msg, colour_timeout, timeout // 10, colour_timeout_msg)
    more.append((timeoutrow * 10 + 0, timeoutmsg))
tabmsg = 'Press [Tab] to edit options'
tabmsg = ' ' * ((width - len(tabmsg)) // 2) + tabmsg
more.append((tabmsgrow * 10 + 1, '\033%s\033%s\033\033' % (colour_tabmsg, tabmsg)))
more.append((helpmsgrow * 10 + 2, helptext))

more = [(x[0] // 10, x[1]) for x in sorted(more, key = lambda x : x[0])]
line = len(text.split('\n')) - vshift

for seg in more:
    if line <= seg[0]:
        text += '\n' * (seg[0] - line) + seg[1] + '\n'
        line = seg[0] + len(seg[1].split('\n'))

text = '\n'.join((text + '\n' * 30).split('\n')[:30])

print(background)
print(width)
print(29)
if DEBUG:
    text = text.replace('\033', '')
print(text, end = '')
sys.stdout.flush()

if not DEBUG:
    os.system('bash -c "psf2txt <(gunzip < \'%s\') /dev/stderr 2>&1 >/dev/null | grep -v ++"' % font.replace('\'', '\'\\\'\''))

