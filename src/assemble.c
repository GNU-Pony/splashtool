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
#define _GNU_SOURCE
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>


#define WIDTH   640
#define HEIGHT  480


static __attribute__((const)) double linear(unsigned long c)
{
  if (c <= 10)
    return (double)c / (255. * 12.92);
  return pow(((double)c  + 14.025) / 269.025, 2.4);
}


static __attribute__((const)) unsigned long join(unsigned long fg, unsigned long bg, unsigned long alpha)
{
  double t = (double)alpha * linear(fg) + (double)(255 - alpha) * linear(bg);
  t /= 255.;
  if (t <= 0.00304)
    t *= 12.92;
  else
    t = 1.055 * pow(t, 1.0 / 2.4) - 0.055;
  return (unsigned long)(255. * t + 0.5);
}


static inline void subpixels(unsigned long p, unsigned long* a,
			     unsigned long* r, unsigned long* g, unsigned long* b)
{
  *a = (p >> 24) & 255;
  *r = (p >> 16) & 255;
  *g = (p >>  8) & 255;
  *b = (p >>  0) & 255;
}


static void buffer_join(unsigned long* restrict restrict* layer, unsigned long* restrict* restrict base,
			unsigned long width, unsigned long height, unsigned long offx, unsigned long offy)
{
  unsigned long x, y, a, r, g, b;
  unsigned long* restrict layer_column;
  unsigned long* restrict base_column;
  base += offx;
  for (x = 0; x < width; x++)
    {
      layer_column = *layer++;
      base_column = *base++ + offy;
      for (y = 0; y < height; y++, base_column++)
	{
	  subpixels(*layer_column++, &a, &r, &g, &b);
	  if (a == 255)
	    *base_column = (r << 16) | (g << 8) | b;
	}
    }
}


static void widescreen(unsigned long* restrict* restrict rc, unsigned long* restrict* restrict img)
{
  unsigned long x, y, e, rgb;
  unsigned long a1, r1, g1, b1, a2, r2, g2, b2;
  for (y = 0; y < HEIGHT; y++)
    for (x = 0, e = 0; x < WIDTH; x++)
      if (rc[x + e][y] = img[x][y], x % 3 == 2)
	{
	  if (rgb = img[x][y], x < WIDTH - 1)
	    {
	      subpixels(rgb, &a1, &r1, &g1, &b1);
	      subpixels(img[x + 1][y], &a2, &r2, &g2, &b2);
	      r1 = ((r1 + r2) / 2) << 16;
	      g1 = ((g1 + g2) / 2) << 8;
	      b1 = ((b1 + b2) / 2) << 0;
	      rgb = r1 | g1 | b1;
	    }
	  rc[x + ++e][y] = rgb;
	}
}


static unsigned long* restrict* make_buffer(unsigned long n, unsigned long m)
{
  unsigned long i;
  unsigned long* restrict* restrict rc = malloc(n * sizeof(unsigned long*));
  for (i = 0; i < n; i++)
    rc[i] = calloc(m, sizeof(unsigned long));
  return rc;
}


static void free_buffer(unsigned long* restrict* restrict buffer, unsigned long n)
{
  unsigned long i;
  for (i = 0; i < n; i++)
    free(buffer[i]);
# pragma GCC diagnostic push
# pragma GCC diagnostic ignored "-Wcast-qual"
  free((unsigned long**)buffer);
# pragma GCC diagnostic pop
}


static unsigned long* restrict* load_p6(const char* restrict filename)
{
  unsigned char* restrict data = malloc((size_t)(WIDTH * HEIGHT * 3) * sizeof(unsigned char));
  unsigned long* restrict* restrict rc = make_buffer(WIDTH, HEIGHT);
  unsigned long y, x, p = 0;
  ssize_t got;
  int fd;
  
  fd = open(filename, O_RDONLY);
  while (p < (unsigned long)(WIDTH * HEIGHT * 3))
    {
      got = read(fd, data + p, ((unsigned long)(WIDTH * HEIGHT * 3) - p) * sizeof(char));
      if (got <= 0)
	if ((got == 0) || (errno != EINTR))
	  abort();
      if (got > 0)
	p += (unsigned long)got;
    }
  close(fd);
  
  for (y = 0; y < HEIGHT; y++)
    for (x = 0; x < WIDTH; x++)
      {
	unsigned long r = (unsigned long)(*data++);
	unsigned long g = (unsigned long)(*data++);
	unsigned long b = (unsigned long)(*data++);
	rc[x][y] = (r << 16) | (g << 8) | b;
      }

  free(data - WIDTH * HEIGHT * 3);
  return rc;
}


static char* next_line(void)
{
  static char buf[512];
  unsigned long ptr = 0;
  char c;
  while (c = (char)getchar(), c != '\n')
    buf[ptr++] = c;
  buf[ptr] = '\0';
  return buf;
}


int main(int argc, char** argv)
{
  unsigned long y, x, i, n, ci, yi, xi, offx, offy, width, height;
  unsigned long back = 0, fore = 0, chars, chary, charx;
  unsigned long long foreback = 0;
  unsigned long* restrict chr;
  char* restrict line;
  unsigned long* restrict* restrict charmap;
  char* restrict splash_filename;
  unsigned long* restrict* restrict splash;
  unsigned long* restrict* restrict background;
  unsigned long* restrict* restrict foreground;
  unsigned long* restrict* restrict shadow;
  char** restrict rows;
  
  /* Read image data. */
  splash_filename = strdup(next_line());
  width = (unsigned long)atol(next_line());
  height = (unsigned long)atol(next_line());
  rows = malloc(height * sizeof(char*));
  for (i = 0; i < height; i++)
    rows[i] = strdup(next_line());
  
  /* Read font data. */
  chars = (unsigned long)atol(next_line());
  charx = (unsigned long)atol(next_line());
  chary = (unsigned long)atol(next_line());
  charmap = malloc(chars * sizeof(unsigned long*));
  for (i = 0; i < chars; i++)
    {
      charmap[i] = calloc(chary, sizeof(unsigned long));
      for (y = 0; y < chary; y++)
	for (line = next_line(), x = 0; x < charx; x++)
	  charmap[i][y] |= (line[x] == ' ' ? 0UL : 1UL) << x;
    }
  
  /* The overlay should be centered on the background. */
  offx = (WIDTH - width * charx) / 2;
  offy = (HEIGHT - height * chary) / 2;
  
  /* Buffers for layers. */
  splash     = load_p6(splash_filename);
  background = make_buffer(width * charx, height * chary);
  foreground = make_buffer(width * charx, height * chary);
  shadow     = make_buffer(width * charx, height * chary);
  free(splash_filename);
  
  /* Fill largers. */
  for (y = 0; y < height; y++)
    {
      char* restrict row = rows[y];
      char escape = 0;
      for (i = 0, x = 0, n = strlen(row); i < n; i++)
	{
	  char c = row[i];
	  if (c == '\033')
	    {
	      fore = (unsigned long)(foreback >> 32);
	      back = (unsigned long)(foreback & ((1LL << 32) - 1LL));
	      escape ^= 1;
	      foreback = 0;
	    }
	  else if (escape)
	    {
	      if (c == '#')
		continue;
	      foreback <<= 4;
	      foreback |= (unsigned long long)((c & 15) + (c <= '9' ? 0 : 9));
	    }
	  else
	    {
	      if (ci = (unsigned long)(unsigned char)c % chars, c & 0x80)
		{
		  char* restrict s = row + i;
		  i += 2;
		  if      (strstr(s, "┌") == s)  ci = 218;
		  else if (strstr(s, "─") == s)  ci = 196;
		  else if (strstr(s, "┐") == s)  ci = 191;
		  else if (strstr(s, "│") == s)  ci = 179;
		  else if (strstr(s, "├") == s)  ci = 195;
		  else if (strstr(s, "┤") == s)  ci = 180;
		  else if (strstr(s, "└") == s)  ci = 192;
		  else if (strstr(s, "┘") == s)  ci = 217;
		  else
		    i -= 2;
		}
	      chr = charmap[ci];
	      for (yi = 0; yi < chary; yi++)
		for (xi = 0; xi < charx; xi++)
		  {
		    unsigned long xo = (chr[yi] >> xi) & 1;
		    unsigned long t = offx + x * charx + xi + xo;
		    unsigned long rgb = splash[t < WIDTH ? t : (WIDTH - 1)][offy + y * chary + yi];
		    unsigned long _a, r, g, b, ca, cr, cg, cb, c_;
		    unsigned long* restrict* restrict i_;
		    subpixels(rgb, &_a, &r, &g, &b);
		    if (xo)
		      shadow[x * charx + xi][y * chary + yi] = 128UL << 24;
		    c_ = xo == 1 ? fore : back;
		    i_ = xo == 1 ? foreground : background;
		    subpixels(c_, &ca, &cr, &cg, &cb);
		    r = join(cr, r, ca);
		    g = join(cg, g, ca);
		    b = join(cb, b, ca);
		    rgb = (255UL << 24) | (r << 16) | (g << 8) | b;
		    i_[x * charx + xi][y * chary + yi] = rgb;
		    (void) _a;
		  }
	      x++;
	    }
	}
    }
  
  /* Apply layers. */
  width *= charx;
  buffer_join(background, splash, width, height * chary, offx, offy);
  buffer_join(shadow,     splash, width, height * chary, offx, offy);
  buffer_join(foreground, splash, width, height * chary, offx, offy);
  
  free_buffer(background, width);
  free_buffer(foreground, width);
  free_buffer(shadow, width);
  
  /* Make widescreen preview. */
  if (strchr(argv[2], 'W'))
    *strchr(argv[2], 'W') = 'w';
  if ((strstr(argv[2], "-w") == argv[2]) || (strstr(argv[2], "--w") == argv[2]))
    {
      unsigned long* restrict* restrict original = splash;
      width = HEIGHT * 16 / 9;
      splash = make_buffer(width, HEIGHT);
      widescreen(splash, original);
      free_buffer(original, WIDTH);
    }
  else
    width = WIDTH;
  
  /* Print image. */
  printf("P6\n%lu %i\n255\n", width, HEIGHT);
  for (y = 0; y < HEIGHT; y++)
    for (x = 0; x < width; x++)
      {
	unsigned long _a, r, g, b;
	subpixels(splash[x][y], &_a, &r, &g, &b);
	putchar_unlocked((int)r);
	putchar_unlocked((int)g);
	putchar_unlocked((int)b);
      }
  fflush(stdout);
  
  for (i = 0; i < height; i++)
    free(rows[i]);
  free(rows);
  free_buffer(charmap, chars);
  free_buffer(splash, width);
  return 0;
  (void) argc;
}

