{
	Copyright (c) 2020 Adrian Siekierka

	Based on a reconstruction of code from ZZT,
	Copyright 1991 Epic MegaGames, used with permission.

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
unit Video;

interface
	type
		TVideoLine = string[80];
		TVideoWriteTextProc = procedure(x, y, color: byte; text: TVideoLine);
	var
		VideoMonochrome: boolean;
		VideoColumns: integer;
		VideoBorderColor: integer;
		VideoCursorVisible: boolean;
	function VideoConfigure: boolean;
	procedure VideoWriteText(x, y, color: byte; text: TVideoLine);
	procedure VideoInstall(columns, borderColor: integer);
	procedure VideoUninstall;
	procedure VideoShowCursor;
	procedure VideoHideCursor;
	procedure VideoSetBorderColor(value: integer);
	procedure VideoMove(x, y, chars: integer; data: pointer; toVideo: boolean);
	procedure ClrScr;

implementation
uses Dos;

{$I VIDCONST.INC}

{$F+}

procedure VideoWriteText(x, y, color: byte; text: TVideoLine);
	var
		attr: word;
		i, offset: integer;
	begin
		{ manipulate color }
		attr := ATTR_MAP[color and $7F] or ((color and $80) shr 6);
		i := 1;
		offset := (y * VideoColumns + x) * 2;
		repeat
			MemW[$A000:offset] := CP437_MAP[Ord(text[i])];
			MemW[$A200:offset] := attr;
			Inc(offset);
			Inc(offset);
			Inc(i);
		until i > Length(text);
	end;

{$F-}

function VideoConfigure: boolean;
	begin
		VideoConfigure := True;
	end;

procedure VideoInstall(columns, borderColor: integer);
	var
		regs: Registers;
	begin
		{ TODO }
	end;

procedure VideoUninstall;
	var
		regs: Registers;
	begin
		{ TODO }
	end;

procedure VideoShowCursor;
	var
		regs: Registers;
	begin
		regs.AH := $11;
		Intr($18, regs);
		VideoCursorVisible := true;
	end;

procedure VideoHideCursor;
	var
		regs: Registers;
	begin
		regs.AH := $12;
		Intr($18, regs);
		VideoCursorVisible := false;
	end;

procedure VideoSetBorderColor(value: integer);
	begin
		{ TODO }
	end;

procedure VideoMove(x, y, chars: integer; data: pointer; toVideo: boolean);
	var
		offset: integer;
	begin
		offset := (y * VideoColumns + x) * 2;
		if toVideo then begin
			Move(data^, Ptr($A000, offset)^, chars * 2);
			Move(Ptr(Seg(data^), Ofs(data^) + (chars * 2))^, Ptr($A200, offset)^, chars * 2);
		end else begin
			Move(Ptr($A000, offset)^, data^, chars * 2);
			Move(Ptr($A200, offset)^, Ptr(Seg(data^), Ofs(data^) + (chars * 2))^, chars * 2);
		end
	end;

procedure ClrScr;
	var
		regs: Registers;
	begin
		regs.AH := $16;
		regs.DX := $0020;
		Intr($18, regs);
	end;
		
begin
	VideoBorderColor := 0;
	VideoColumns := 80;
	VideoMonochrome := false;
	VideoCursorVisible := true;
end.
