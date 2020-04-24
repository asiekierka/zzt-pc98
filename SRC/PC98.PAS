{
	Copyright (c) 2020 Adrian Siekierka

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
}

{$I-}
unit PC98;

interface
	procedure Delay(ms: integer);

implementation
uses Dos, FONT;

procedure Delay(ms: integer);
	var
		i, j: integer;
	begin
		{ TODO: something sensible }
		for i := 0 to ms do
			for j := 0 to 300 do
				Port[$5F] := $00;
	end;

procedure LoadFontData;
	var
		chr: array[0 .. 33] of byte;
		cPtr: pointer;
		i, j: integer;
		regs: Registers;
	begin
		cPtr := Ptr(Seg(chr), Ofs(chr) + 2);
		for i := 0 to (FONTBINSize shr 4) do begin
			for j := 0 to 15 do begin
				chr[(j shl 1) + 2] := FONTBINData[(i shl 4) or j];
				chr[(j shl 1) + 3] := FONTBINData[(i shl 4) or j];
			end;
			regs.AH := $1A;
			regs.BX := Seg(chr);
			regs.CX := Ofs(chr);
			regs.DX := ($7601 + ((i and $7E) shr 1)) + ((i and $01) shl 8);
			Intr($18, regs);
		end;
	end;

begin
	LoadFontData;
end.
