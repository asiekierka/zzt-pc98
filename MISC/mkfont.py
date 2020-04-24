#!/usr/bin/python3

# Copyright (c) 2020 Adrian Siekierka
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

# format:
# 16-byte 1-bit 8x8 bitmaps for each tile

from PIL import Image
import struct, sys

tiles = []

ranges = [
	(1, 23),
	(28, 31),
	(94, 94),
	(127, 127),
	(128, 178),
	(219, 254)
]
set_order = {}

def write_tile(fp, tile):
	for i in range(0, 16):
		if i >= len(tile):
			fp.write(struct.pack("<B", 0))
		else:
			fp.write(struct.pack("<B", tile[i]))

def add_tile(im, x, y, w, h):
	global tile_ids, tile_by_id, tile_descs
	tile = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	for iy in range(0, h):
		ti = 0
		for ix in range(0, w):
			pxl = im.getpixel((x+ix, y+iy))
			ti = (ti << 1)
			if pxl[0] > 128:
				ti = ti + 1
		tile[iy] = ti
	tile = tuple(tile)
	tiles.append(tile)

im = Image.open(sys.argv[1]).convert("RGBA")
for i in ranges:
	for c in range(i[0], i[1] + 1):
		cx = int(c % 32) * 8
		cy = int(c / 32) * 16
		c_pos = len(tiles)
		add_tile(im, cx, cy, 8, 16)
		set_order[c] = 0x0056 | ((c_pos & 1)) | (((c_pos & 254) << 7) + 256)

set_order[0] = 32
set_order[255] = 32
set_order[0x18] = 30
set_order[0x19] = 31
set_order[0x1A] = 28
set_order[0x1B] = 29

# line chars
set_order[179] = 0x2B26
set_order[180] = 0x2B48
set_order[181] = 0x2B49
set_order[182] = 0x2B4C
set_order[183] = 0x2B36
set_order[184] = 0x2B35
set_order[185] = 0x2B4F
set_order[186] = 0x2B27
set_order[187] = 0x2B37
set_order[188] = 0x2B3F
set_order[189] = 0x2B3E
set_order[190] = 0x2B3D
set_order[191] = 0x2B34
set_order[192] = 0x2B38
set_order[193] = 0x2B58
set_order[194] = 0x2B50
set_order[195] = 0x2B40
set_order[196] = 0x2B24
set_order[197] = 0x2B60
set_order[198] = 0x2B41
set_order[199] = 0x2B44
set_order[200] = 0x2B3B
set_order[201] = 0x2B33
set_order[202] = 0x2B5F
set_order[203] = 0x2B57
set_order[204] = 0x2B47
set_order[205] = 0x2B25
set_order[206] = 0x2B6F
set_order[207] = 0x2B5B
set_order[208] = 0x2B5C
set_order[209] = 0x2B53
set_order[210] = 0x2B54
set_order[211] = 0x2B3A
set_order[212] = 0x2B39
set_order[213] = 0x2B31
set_order[214] = 0x2B32
set_order[215] = 0x2B66
set_order[216] = 0x2B63
set_order[217] = 0x2B3C
set_order[218] = 0x2B30


for c in range(179, 219):
	set_order[c] = ((set_order[c] & 0xFF) << 8) | (((set_order[c] >> 8) - 0x20) & 0xFF)

for c in range(0, 256):
	if c in set_order:
		print("$%04X, " % set_order[c], end='')
	else:
		print("$%04X, " % c, end='')
	if ((c % 16) == 15):
		print("")

with open(sys.argv[2], "wb") as fp:
	for i in range(len(tiles)):
		write_tile(fp, tiles[i])
