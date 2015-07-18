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

module anchovy.core.types;

import std.conv;
public import dlib.math.vector;
public import anchovy.utils.rect;
public import anchovy.utils.rectoffset;
import dlib.math.utils: clampValue = clamp;

enum StatusType : int {
	StatusAppMissingAsset = -4,  ///< Application failed due to missing asset file
	StatusAppStackEmpty   = -3,  ///< Application States stack is empty
	StatusAppInitFailed   = -2,  ///< Application initialization failed
	StatusError           = -1,  ///< General error status response
	StatusAppOK           =  0,  ///< Application quit without error
	StatusNoError         =  0,  ///< General no error status response
	StatusFalse           =  0,  ///< False status response
	StatusTrue            =  1,  ///< True status response
	StatusOK              =  1,  ///< OK status response
};

enum ShaderType : uint {
	FRAGMENT		= 0x8B30,
	VERTEX			= 0x8B31,
	GEOMETRY		= 0x8DD9,
	COMPUTE			= 0x91B9,
	TESS_EVALUATION	= 4,
	TESS_CONTROL	= 5,
}


struct Color
{
	this(ubyte gray)
	{
		r = gray;
		g = gray;
		b = gray;
		a = 255;
	}

	this(ubyte r, ubyte g, ubyte b, ubyte a = 255)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	ubyte r, g, b, a;
}

struct Color4f
{
	float r, g, b, a;

	this(Color col)
	{
		r=cast(float)col.r/255;
		g=cast(float)col.g/255;
		b=cast(float)col.b/255;
		a=cast(float)col.a/255;
	}
	this(float a, float b, float c, float d = 1.0f)
	{
		this.r = a;
		this.g = b;
		this.b = c;
		this.a = d;
	}

	bool opEquals()(auto ref const Color4f rc) inout
	{
		return r == rc.r && g == rc.g && b == rc.b && a == rc.a;
	}
}

class IdArray(T)
{
	uint add(T newElement)
	{
		array[currentId] = newElement;
		return currentId++;
	}

	T remove(uint id)
	{
		T temp = array[id];
		array.remove(id);
		return temp;
	}

	/// Deprecated: use array[index] instead
	deprecated T get(uint id)
	{
		T* item = id in array;
		return (item is null) ? null: *item;
	}

	T opIndex(uint index)
	in
	{
		assert(index < currentId);
	}
	body
	{
		T* item = index in array;
		return (item is null) ? null: *item;
	}

	T opIndexAssign(T value, uint index)
	in
	{
		assert(index < currentId);
	}
	body
	{
		array[index] = value;
		return array[index];
	}

	uint currentId = 1;
	T[uint] array;
}
