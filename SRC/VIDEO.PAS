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
const
	CP437_MAP: array[0 .. 255] of word = (
$0020, $0156, $0157, $0256, $0257, $0356, $0357, $0456, $0457, $0556, $0557, $0656, $0657, $0756, $0757, $0856, 
$0857, $0956, $0957, $0A56, $0A57, $0B56, $0B57, $0C56, $001E, $001F, $001C, $001D, $0C57, $0D56, $0D57, $0E56, 
$0020, $0021, $0022, $0023, $0024, $0025, $0026, $0027, $0028, $0029, $002A, $002B, $002C, $002D, $002E, $002F, 
$0030, $0031, $0032, $0033, $0034, $0035, $0036, $0037, $0038, $0039, $003A, $003B, $003C, $003D, $003E, $003F, 
$0040, $0041, $0042, $0043, $0044, $0045, $0046, $0047, $0048, $0049, $004A, $004B, $004C, $004D, $004E, $004F, 
$0050, $0051, $0052, $0053, $0054, $0055, $0056, $0057, $0058, $0059, $005A, $005B, $005C, $005D, $0E57, $005F, 
$0060, $0061, $0062, $0063, $0064, $0065, $0066, $0067, $0068, $0069, $006A, $006B, $006C, $006D, $006E, $006F, 
$0070, $0071, $0072, $0073, $0074, $0075, $0076, $0077, $0078, $0079, $007A, $007B, $007C, $007D, $007E, $0F56, 
$0F57, $1056, $1057, $1156, $1157, $1256, $1257, $1356, $1357, $1456, $1457, $1556, $1557, $1656, $1657, $1756, 
$1757, $1856, $1857, $1956, $1957, $1A56, $1A57, $1B56, $1B57, $1C56, $1C57, $1D56, $1D57, $1E56, $1E57, $1F56, 
$1F57, $2056, $2057, $2156, $2157, $2256, $2257, $2356, $2357, $2456, $2457, $2556, $2557, $2656, $2657, $2756, 
$2757, $2856, $2857, $260B, $480B, $490B, $4C0B, $360B, $350B, $4F0B, $270B, $370B, $3F0B, $3E0B, $3D0B, $340B, 
$380B, $580B, $500B, $400B, $240B, $600B, $410B, $440B, $3B0B, $330B, $5F0B, $570B, $470B, $250B, $6F0B, $5B0B, 
$5C0B, $530B, $540B, $3A0B, $390B, $310B, $320B, $660B, $630B, $3C0B, $300B, $2956, $2957, $2A56, $2A57, $2B56, 
$2B57, $2C56, $2C57, $2D56, $2D57, $2E56, $2E57, $2F56, $2F57, $3056, $3057, $3156, $3157, $3256, $3257, $3356, 
$3357, $3456, $3457, $3556, $3557, $3656, $3657, $3756, $3757, $3856, $3857, $3956, $3957, $3A56, $3A57, $0020
	);
var
	attrMap: array[0 .. 255] of word;

procedure VideoBuildAttrMap;
	var
		i: byte;
		attr: word;
	begin
		for i := 0 to 255 do begin
			attr := $00;
			if (i and $0F) = $00 then begin
				attr := attr
					or $04
					or ((i and $40) shl 0)
					or ((i and $20) shl 2)
					or ((i and $10) shl 1);
			end else if (i and $0F) = $08 then begin
				attr := attr or $E0;
			end else begin
				attr := attr
					or ((i and $04) shl 4)
					or ((i and $02) shl 6)
					or ((i and $01) shl 5);
			end;
			if (i and $80) <> 0 then
				attr := attr or $02;
			attrMap[i] := attr or $01;
		end;
	end;

{$F+}

procedure VideoWriteText(x, y, color: byte; text: TVideoLine);
	var
		attr: word;
		i, offset: integer;
	begin
		{ manipulate color }
		attr := attrMap[color];
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
	VideoBuildAttrMap;
end.
