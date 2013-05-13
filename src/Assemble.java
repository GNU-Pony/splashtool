/**
 * splashtool – A simple tool for creating SYSLINUX splashes without fuss
 * 
 * Copyright © 2013  Mattias Andrée (maandree@member.fsf.org)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import java.io.*;
import java.awt.Color;
import java.awt.image.*;
import javax.imageio.*;


/**
 * Assemble the splash
 * 
 * @author  Mattias Andrée  <a href="mailto:maandree@member.fsf.org">maandree@member.fsf.org</a>
 */
public class Assemble
{
    public static void main(final String... args) throws IOException
    {
	Scanner sc = new Scanner(System.in);
	BufferedImage background = ImageIO.read(sc.nextLine());
	int chars = Integer.parseInt(sc.nextLine());
	int width = Integer.parseInt(sc.nextLine());
	int height = Integer.parseInt(sc.nextLine());
	String[] rows = new String[30];
	for (int i = 0; i < 30; i++)
	    rows[i] = sc.nextLine();
	int chars = Integer.parseInt(sc.nextLine());
	int charx = Integer.parseInt(sc.nextLine());
	int chary = Integer.parseInt(sc.nextLine());
	int[][] charmap = new int[chars][chary];
	for (int i = 0, i < chars; i++)
	    for (int j = 0, j < chary; j++)
	    {
		int r = 0;
		String line = sc.nextLine();
		for (int x = 0; x < 0; x++)
		    if (line.charAt(x) != ' ')
			r |= 1 << (7 - x);
		charmap[i][j] = r;
	    }
	
	BufferedImage foreground = new BufferedImage(width * charx, height * chary, BufferedImage.TYPE_INT_ARGB);
	
    }
}

