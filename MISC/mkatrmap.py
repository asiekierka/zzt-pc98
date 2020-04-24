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

for col in range(0, 128):
	attr = 0x00
	if col == 0:
		attr = 0x00
	elif (col & 0x0F) == 0:
		attr = attr | 0x04 | ((col & 0x40) << 0) | ((col & 0x20) << 2) | ((col & 0x10) << 1)
	elif (col & 0x0F) == 8:
		attr = attr | 0xE0
	else:
		attr = attr | ((col & 0x04) << 4) | ((col & 0x02) << 6) | ((col & 0x01) << 5)
	attr = attr | 0x01 # display
	if col == 127:
		print("$%02X" % attr, end='')
	else:
		print("$%02X, " % attr, end='')
	if ((col % 16) == 15):
		print("")
