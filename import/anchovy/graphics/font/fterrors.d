/*
Copyright (c) 2013 Andrey Penechko

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license the "Software" to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module anchovy.graphics.font.fterrors;

import std.conv: to;

import derelict.freetype.ft;

void checkFtError(FT_Error error, string file = __FILE__, size_t line = __LINE__)
{
	if (error != 0)
	{
		throw new FreeTypeException(error, file, line);
	}
}

class FreeTypeException : Exception
{
	this(uint errorCode, string file = __FILE__, size_t line = __LINE__)
	{
		super("FreeType error [" ~ to!string(errorCode) ~ "] " ~ ftErrorStringTable[errorCode], file, line);
	}
}

static const string[uint] ftErrorStringTable;

static this()
{
	ftErrorStringTable = 
	[0x00 : "Ok",
	 0x01 : "Cannot Open Resource",
	 0x02 : "Unknown File Format",
	 0x03 : "Invalid File Format",
	 0x04 : "Invalid Version",
	 0x05 : "Lower Module Version",
	 0x06 : "Invalid Argument",
	 0x07 : "Unimplemented Feature",
	 0x08 : "Invalid Table",
	 0x09 : "Invalid Offset",
	 0x10 : "Invalid Glyph Index",
	 0x11 : "Invalid Character Code",
	 0x12 : "Invalid Glyph Format",
	 0x13 : "Cannot Render Glyph",
	 0x14 : "Invalid Outline",
	 0x15 : "Invalid Composite",
	 0x16 : "Too Many Hints",
	 0x17 : "Invalid Pixel Size",
	 0x20 : "Invalid Handle",
	 0x21 : "Invalid Library Handle",
	 0x22 : "Invalid Driver Handle",
	 0x23 : "Invalid Face Handle",
	 0x24 : "Invalid Size Handle",
	 0x25 : "Invalid Slot Handle",
	 0x26 : "Invalid CharMap Handle",
	 0x27 : "Invalid Cache Handle",
	 0x28 : "Invalid Stream Handle",
	 0x30 : "Too Many Drivers",
	 0x31 : "Too Many Extensions",
	 0x40 : "Out Of Memory",
	 0x41 : "Unlisted Object",
	 0x51 : "Cannot Open Stream",
	 0x52 : "Invalid Stream Seek",
	 0x53 : "Invalid Stream Skip",
	 0x54 : "Invalid Stream Read",
	 0x55 : "Invalid Stream Operation",
	 0x56 : "Invalid Frame Operation",
	 0x57 : "Nested Frame Access",
	 0x58 : "Invalid Frame Read",
	 0x60 : "Raster Uninitialized",
	 0x61 : "Raster Corrupted",
	 0x62 : "Raster Overflow",
	 0x63 : "Raster Negative Height",
	 0x70 : "Too Many Caches",
	 0x80 : "Invalid Opcode",
	 0x81 : "Too Few Arguments",
	 0x82 : "Stack Overflow",
	 0x83 : "Code Overflow",
	 0x84 : "Bad Argument",
	 0x85 : "Divide By Zero",
	 0x86 : "Invalid Reference",
	 0x87 : "Debug OpCode",
	 0x88 : "ENDF In Exec Stream",
	 0x89 : "Nested DEFS",
	 0x8A : "Invalid CodeRange",
	 0x8B : "Execution Too Long",
	 0x8C : "Too Many Function Defs",
	 0x8D : "Too Many Instruction Defs",
	 0x8E : "Table Missing",
	 0x8F : "Horiz Header Missing",
	 0x90 : "Locations Missing",
	 0x91 : "Name Table Missing",
	 0x92 : "CMap Table Missing",
	 0x93 : "Hmtx Table Missing",
	 0x94 : "Post Table Missing",
	 0x95 : "Invalid Horiz Metrics",
	 0x96 : "Invalid CharMap Format",
	 0x97 : "Invalid PPem",
	 0x98 : "Invalid Vert Metrics",
	 0x99 : "Could Not Find Context",
	 0x9A : "Invalid Post Table Format",
	 0x9B : "Invalid Post Table",
	 0xA0 : "Syntax Error",
	 0xA1 : "Stack Underflow",
	 0xA2 : "Ignore",
	 0xB0 : "Missing Startfont Field",
	 0xB1 : "Missing Font Field",
	 0xB2 : "Missing Size Field",
	 0xB3 : "Missing Chars Field",
	 0xB4 : "Missing Startchar Field",
	 0xB5 : "Missing Encoding Field",
	 0xB6 : "Missing Bbx Field"
 	];
	ftErrorStringTable.rehash;
}