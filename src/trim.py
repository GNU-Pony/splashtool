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


text = False

while True:
    try:
        line = input().replace('\t', ' ')
        lower = line.lower()
        if line.replace(' ', '').startswith('#') or (len(line.replace(' ', '')) == 0):
            continue
        else:
            if ' # ' in line:
                line = line[:line.find(' # ')]
                lower = lower[:lower.find(' # ')]
            while line.startswith(' '):
                line = line[1:]
                lower = lower[1:]
            while line.endswith(' '):
                line = line[:-1]
                lower = lower[:-1]
            
            if lower.startswith('text '):
                text = True
                print(line)
            elif lower == 'endtext':
                text = False
                print(line)
            elif text or (lower.split(' ')[0] in ('timeout', 'menu', 'label', 'font')):
                print(line)
    except:
        break

