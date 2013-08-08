/**
 * splashtool – A simple tool for creating SYSLINUX splashes without fuss
 * 
 * Copyright © 2013  Mattias Andrée (maandree@member.fsf.org)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import java.io.*;
import java.util.*;
import java.awt.*;
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
	ImageIO.scanForPlugins();
	Scanner sc = new Scanner(System.in);
	BufferedImage splash = ImageIO.read(new BufferedInputStream(new FileInputStream(new File(sc.nextLine()))));
	int width = Integer.parseInt(sc.nextLine());
	int height = Integer.parseInt(sc.nextLine());
	String[] rows = new String[height];
	for (int i = 0; i < height; i++)
	    rows[i] = sc.nextLine();
	int chars = Integer.parseInt(sc.nextLine());
	int charx = Integer.parseInt(sc.nextLine());
	int chary = Integer.parseInt(sc.nextLine());
	int[][] charmap = new int[chars][chary];
	for (int i = 0; i < chars; i++)
	    for (int j = 0; j < chary; j++)
	    {
		int r = 0;
		String line = sc.nextLine();
		for (int x = 0; x < charx; x++)
		    if (line.charAt(x) != ' ')
			r |= 1 << x;
		charmap[i][j] = r;
	    }
	
	int offx = (640 - width * charx) / 2, offy = (480 - height * chary) / 2;
	
	BufferedImage background = new BufferedImage(width * charx, height * chary, BufferedImage.TYPE_INT_ARGB);
	BufferedImage foreground = new BufferedImage(width * charx, height * chary, BufferedImage.TYPE_INT_ARGB);
	BufferedImage shadow = new BufferedImage(width * charx, height * chary, BufferedImage.TYPE_INT_ARGB);
	
	int fore = 0;
	int back = 0;
	long foreback = 0;
	
	for (int y = 0; y < height; y++)
	{
	    int x = 0;
	    String row = rows[y];
	    boolean escape = false;
	    for (int i = 0, n = row.length(); i < n; i++)
	    {
		char c = row.charAt(i);
		if (c == '\033')
		{
		    fore = (int)(foreback >> 32);
		    back = (int)foreback;
		    escape ^= true;
		    foreback = 0;
		}
		else if (escape)
		{
		    if (c == '#')
			continue;
		    foreback = (foreback << 4) | ((c & 15) + (c <= '9' ? 0 : 9));
		}
		else
		{
		    int ci = c % chars;
		    if      (c == '┌')  ci = 218;
		    else if (c == '─')  ci = 196;
		    else if (c == '┐')  ci = 191;
		    else if (c == '│')  ci = 179;
		    else if (c == '├')  ci = 195;
		    else if (c == '┤')  ci = 180;
		    else if (c == '└')  ci = 192;
		    else if (c == '┘')  ci = 217;
		    int[] chr = charmap[ci];
		    int t;
		    for (int yi = 0; yi < chary; yi++)
			for (int xi = 0; xi < charx; xi++)
			{
			    int xo = (chr[yi] >>> xi) & 1;
			    int a, rgb = splash.getRGB((t = offx + x * charx + xi + xo) > 639 ? 639 : t, offy + y * chary + yi);
			    int r = (rgb >> 16) & 255;
			    int g = (rgb >> 8) & 255;
			    int b = rgb & 255;
			    if (xo == 1)
			    {
				a = fore >>> 24;
				shadow.setRGB(x * charx + xi, y * chary + yi, 128 << 24);
				r = join((fore >> 16) & 255, r, a);
				g = join((fore >>  8) & 255, g, a);
				b = join((fore >>  0) & 255, b, a);
				rgb = (255 << 24) | (r << 16) | (g << 8) | b;
				foreground.setRGB(x * charx + xi, y * chary + yi, rgb);
			    }
			    else
			    {
				a = back >>> 24;
				r = join((back >> 16) & 255, r, a);
				g = join((back >>  8) & 255, g, a);
				b = join((back >>  0) & 255, b, a);
				rgb = (255 << 24) | (r << 16) | (g << 8) | b;
				background.setRGB(x * charx + xi, y * chary + yi, rgb);
			    }
			}
		    x++;
		}
	    }
	}
	
	Graphics g = splash.createGraphics();
	g.drawImage(background, offx, offy, null);
	g.drawImage(shadow, offx + 1, offy + 1, null);
	g.drawImage(foreground, offx, offy, null);
	g.dispose();
	
	if (args[1].toLowerCase().startsWith("-w") || args[1].toLowerCase().startsWith("--w"))
	    splash = widescreen(splash);
	
	ImageIO.write(splash, "png", new BufferedOutputStream(new FileOutputStream(new File(args[0]))));
    }
    
    
    private static BufferedImage widescreen(BufferedImage img)
    {
	BufferedImage rc = new BufferedImage(480 * 16 / 9, 480, BufferedImage.TYPE_INT_ARGB);
	for (int y = 0; y < 480; y++)
	    for (int x = 0, e = 0; x < 640; x++)
	    {
		rc.setRGB(x + e, y, img.getRGB(x, y));
		if (x % 3 == 2)
		    if (x == 639)
			rc.setRGB(x + ++e, y, img.getRGB(x, y));
		    else
		    {
			int argb1 = img.getRGB(x, y);
			int argb2 = img.getRGB(x + 1, y);
			int a = (argb1 >>> 24) + (argb2 >>> 24);
			int r = ((argb1 >> 16) & 255) + ((argb2 >> 16) & 255);
			int g = ((argb1 >> 8) & 255) + ((argb2 >> 8) & 255);
			int b = (argb1 & 255) + (argb2 & 255);
			rc.setRGB(x + ++e, y, ((a >> 1) << 24) | ((r >> 1) << 16) | ((g >> 1) << 8) | (b >> 1));
		    }
	    }
	return rc;
    }
    
    
    private static int join(int fg, int bg, int alpha)
    {
	double t = alpha * linear(fg) + (255 - alpha) * linear(bg);
	t /= 255;
	if (t <= 0.00304)
	    t *= 12.92;
	else
	    t = 1.055 * Math.pow(t, 1 / 2.4) - 0.055;
	return (int)(255 * t + 0.5);
    }
    
    private static double linear(int c)
    {
	if (c <= 10)
	    return c / (255 * 12.92);
	return Math.pow((c + 14.025) / 269.025, 2.4);
    }
    
}

