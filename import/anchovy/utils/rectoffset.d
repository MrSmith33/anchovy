module anchovy.utils.rectoffset;

import std.conv;

/++
 + Offset for different things like borders
 +/
struct RectOffset
{
	union
	{
		struct
		{
			int left;
			int right;
			int top;
			int bottom;
		}
		int[4] arrayof;
	}

	string toString() const
	{
		return to!string(arrayof);
	}

	this(int a)
	{
		left = a;
		right = a;
		top = a;
		bottom = a;
	}

	this(int[4] array)
	{
		arrayof = array;
	}

	this(int a, int b, int c, int d)
	{
		left = a;
		right = b;
		top = c;
		bottom = d;
	}

	int horizontal() @property @safe nothrow
	{
		return left + right;
	}

	int vertical() @property @safe nothrow
	{
		return top + bottom;
	}
}

unittest
{
	RectOffset ro = RectOffset(10, 15, 20, 25);

	assert(ro.horizontal == ro.left + ro.right);
	assert(ro.vertical == ro.top + ro.bottom);
}