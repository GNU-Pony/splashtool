/**
 * splashtool – A simple tool for creating SYSLINUX splashes without fuss
 * 
 * Copyright © 2013, 2014  Mattias Andrée (maandree@member.fsf.org)
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
    
}

