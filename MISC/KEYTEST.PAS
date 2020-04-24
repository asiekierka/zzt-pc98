{
	PC98 key testing program

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

program KeyTest;

uses Dos;

function KeyPressed: boolean;
	var
		regs: Registers;
	begin
		regs.AH := $01;
		Intr($18, regs);
{		KeyPressed := (regs.Flags and $02) <> 0; }
		KeyPressed := regs.BH <> 0;
	end;

function ReadKey: char;
	var
		regs: Registers;
	begin
		regs.AH := $00;
		Intr($18, regs);
		if (regs.AL <= $02) and (regs.AH <= $80) then
			ReadKey := Chr(regs.AH or $80)
		else
			ReadKey := Chr(regs.AL);
	end;

var
	c: char;
	running: boolean;
begin
	running := true;
	while running do begin
		if KeyPressed then begin
			c := ReadKey;
			if c = #13 then
				running := false
			else
				Writeln('Read character ', Ord(c));
		end;
	end;
end.
