#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# splashtool – A simple tool for creating SYSLINUX splashes without fuss
# 
# Copyright © 2013, 2014  Mattias Andrée (maandree@member.fsf.org)
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


text = False
firsttext = True

while True:
    try:
        line = input()
        lower = line.lower()
        if lower.startswith('text '):
            text = True
            if firsttext:
                print(line)
        elif lower == 'endtext':
            text = False
            if firsttext:
                print(line)
                firsttext = False
        elif (text and firsttext) or (lower.split(' ')[0] in ('timeout', 'menu', 'font')):
            print(line)
    except:
        break

